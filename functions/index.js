const functions = require("firebase-functions");
const admin = require("firebase-admin");
const XLSX = require("xlsx");

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

/**
 * HTTP Cloud Function to parse Excel files (.xls or .xlsx)
 * Returns parsed JSON data ready for import
 */
exports.parseExcelFile = functions
    .region("asia-south1")
    .runWith({
      timeoutSeconds: 120,
      memory: "512MB",
    })
    .https.onRequest(async (req, res) => {
      // Handle CORS
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // Handle preflight request
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // Only allow POST
      if (req.method !== "POST") {
        res.status(405).json({success: false, error: "Method not allowed"});
        return;
      }

      try {
        const data = req.body;

        // Validate input
        if (!data || !data.fileBase64) {
          res.status(400).json({
            success: false,
            error: "Missing fileBase64 parameter",
          });
          return;
        }

        const fileName = data.fileName || "file.xlsx";

        // Decode base64 to buffer
        const fileBuffer = Buffer.from(data.fileBase64, "base64");

        // Read the Excel file (supports both .xls and .xlsx)
        const workbook = XLSX.read(fileBuffer, {
          type: "buffer",
          cellDates: true,
          cellNF: true,
          cellText: true,
          raw: false,
        });

        // Check all sheets
        const allSheetNames = workbook.SheetNames;
        if (allSheetNames.length === 0) {
          res.status(400).json({
            success: false,
            error: "Excel file has no sheets",
          });
          return;
        }

        // Log sheet info
        console.log("Sheet names:", allSheetNames);

        // Try to find the sheet with the most data
        let bestSheet = null;
        let bestSheetName = allSheetNames[0];
        let maxRows = 0;

        for (const name of allSheetNames) {
          const s = workbook.Sheets[name];
          const range = s["!ref"];
          if (range) {
            const decoded = XLSX.utils.decode_range(range);
            const rows = decoded.e.r - decoded.s.r + 1;
            console.log(`Sheet "${name}": range=${range}, rows=${rows}`);
            if (rows > maxRows) {
              maxRows = rows;
              bestSheet = s;
              bestSheetName = name;
            }
          }
        }

        const sheet = bestSheet || workbook.Sheets[allSheetNames[0]];
        const sheetName = bestSheetName;

        // Check for and log merged cells
        const merges = sheet["!merges"] || [];
        console.log("Merged cells count:", merges.length);
        if (merges.length > 0) {
          console.log("Sample merges:", merges.slice(0, 5));
        }

        // Convert to JSON with headers - use defval to fill empty cells
        // and blankrows: false to skip truly empty rows
        const jsonData = XLSX.utils.sheet_to_json(sheet, {
          header: 1, // Use array format first to get headers
          defval: "",
          raw: false,
          dateNF: "yyyy-mm-dd",
          blankrows: false, // Skip blank rows
        });

        if (jsonData.length < 2) {
          res.status(400).json({
            success: false,
            error: "Excel file has no data rows",
          });
          return;
        }

        // Find the header row (look for rows containing known column names)
        const knownHeaders = [
          "event type", "event no", "eventtype", "eventno",
          "reserve price", "reserveprice", "property category",
        ];

        let headerRowIndex = 0;
        for (let i = 0; i < Math.min(jsonData.length, 10); i++) {
          const row = jsonData[i];
          if (!row || row.length === 0) continue;

          const rowText = row.map((c) =>
            String(c || "").toLowerCase().trim()
          ).join(" ");

          // Check if this row contains any known headers
          const matchCount = knownHeaders.filter((h) =>
            rowText.includes(h)
          ).length;

          if (matchCount >= 2) {
            headerRowIndex = i;
            break;
          }
        }

        // Get headers from the detected row
        const headers = jsonData[headerRowIndex].map((h) =>
          String(h || "").toLowerCase().trim(),
        );

        // Column mappings (normalized lowercase to field name)
        const columnMappings = {
          // Event info
          "event type": "eventType",
          "eventtype": "eventType",
          "event no": "eventNo",
          "eventno": "eventNo",
          "event_no": "eventNo",
          "nit ref. no": "nitRefNo",
          "nit ref no": "nitRefNo",
          "nitrefno": "nitRefNo",
          "tender/event title": "eventTitle",
          "tenderevent title": "eventTitle",
          "event title": "eventTitle",
          "eventtitle": "eventTitle",
          "event bank:": "eventBank",
          "event bank": "eventBank",
          "eventbank": "eventBank",
          "event branch:": "eventBranch",
          "event branch": "eventBranch",
          "eventbranch": "eventBranch",

          // Property info
          "property category": "propertyCategory",
          "propertycategory": "propertyCategory",
          "property sub category:": "propertySubCategory",
          "property sub category": "propertySubCategory",
          "propertysubcategory": "propertySubCategory",
          "property description:": "propertyDescription",
          "property description": "propertyDescription",
          "propertydescription": "propertyDescription",
          "borrower's name": "borrowerName",
          "borrowers name": "borrowerName",
          "borrowername": "borrowerName",

          // Pricing
          "reserve price:": "reservePrice",
          "reserve price": "reservePrice",
          "reserveprice": "reservePrice",
          "tender fee:": "tenderFee",
          "tender fee": "tenderFee",
          "tenderfee": "tenderFee",
          "price bid:": "priceBid",
          "price bid": "priceBid",
          "pricebid": "priceBid",
          "bid increment value": "bidIncrementValue",
          "bidincrementvalue": "bidIncrementValue",
          "bid_increment_value": "bidIncrementValue",

          // Extension
          "auto extension time": "autoExtensionTime",
          "autoextensiontime": "autoExtensionTime",
          "no. of auto extension": "noOfAutoExtension",
          "no of auto extension": "noOfAutoExtension",
          "noofautoextension": "noOfAutoExtension",

          // DSC
          "dsc required:": "dscRequired",
          "dsc required": "dscRequired",
          "dscrequired": "dscRequired",

          // EMD
          "emd amount:": "emdAmount",
          "emd amount": "emdAmount",
          "emdamount": "emdAmount",
          "emd deposit bank name": "emdBankName",
          "emddepositbankname": "emdBankName",
          "emd deposit bank account number": "emdAccountNo",
          "emddepositbankaccountnumber": "emdAccountNo",
          "emd deposit bank ifsc code:": "emdIfscCode",
          "emd deposit bank ifsc code": "emdIfscCode",
          "emddepositbankifsccode": "emdIfscCode",

          // Dates
          "press release date": "pressReleaseDate",
          "pressreleasedate": "pressReleaseDate",
          "date of inspection  of property (from):": "inspectionDateFrom",
          "date of inspection of property (from):": "inspectionDateFrom",
          "date of inspection of property (from)": "inspectionDateFrom",
          "inspectiondatefrom": "inspectionDateFrom",
          "date of inspection of property (to):": "inspectionDateTo",
          "date of inspection of property (to)": "inspectionDateTo",
          "inspectiondateto": "inspectionDateTo",
          "offer (first round quote) submission last date:": "submissionLastDate",
          "offer (first round quote) submission last date": "submissionLastDate",
          "submissionlastdate": "submissionLastDate",
          "offer (first round quote) opening date:": "offerOpeningDate",
          "offer (first round quote) opening date": "offerOpeningDate",
          "offeropeningdate": "offerOpeningDate",
          "auction start date and time:": "auctionStartDate",
          "auction start date and time": "auctionStartDate",
          "auctionstartdate": "auctionStartDate",
          "auction end date and time": "auctionEndDate",
          "auction end date and time:": "auctionEndDate",
          "auctionenddate": "auctionEndDate",

          // Documents
          "documents to be submitted": "documentsRequired",
          "documentstobesubmitted": "documentsRequired",
          "paper publishing": "paperPublishingUrl",
          "paperpublishing": "paperPublishingUrl",
          "annexure 2/details of bidder": "detailsOfBidderUrl",
          "annexure2detailsofbidder": "detailsOfBidderUrl",
          "annexure 3/declaration by bidders": "declarationUrl",
          "annexure3declarationbybidders": "declarationUrl",
        };

        // Create column index map
        const columnIndexMap = {};
        headers.forEach((header, index) => {
          const fieldName = columnMappings[header];
          if (fieldName) {
            columnIndexMap[fieldName] = index;
          }
        });

        // Parse data rows (start after header row)
        const parsedRows = [];
        const errors = [];
        const dataStartRow = headerRowIndex + 1;
        const skippedRows = []; // Debug info

        for (let i = dataStartRow; i < jsonData.length; i++) {
          const row = jsonData[i];

          // Skip completely empty rows
          if (!row || row.length === 0) {
            skippedRows.push({row: i, reason: "empty row"});
            continue;
          }

          try {
            // Helper to get cell value
            const getCellValue = (fieldName, defaultValue = "") => {
              const index = columnIndexMap[fieldName];
              if (index === undefined || index >= row.length) {
                return defaultValue;
              }
              const value = row[index];
              if (value === null || value === undefined) return defaultValue;
              return String(value).trim();
            };

            // Helper to get numeric value
            const getNumericValue = (fieldName, defaultValue = 0) => {
              const value = getCellValue(fieldName);
              if (!value) return defaultValue;
              const cleaned = value.replace(/[,\s]/g, "");
              const num = parseFloat(cleaned);
              return isNaN(num) ? defaultValue : num;
            };

            // Helper to parse date
            const getDateValue = (fieldName) => {
              const value = getCellValue(fieldName);
              if (!value || value.toLowerCase() === "download") return null;

              // Try parsing as date
              const date = new Date(value);
              if (!isNaN(date.getTime())) {
                return date.toISOString();
              }

              // Try dd-mm-yyyy format
              const parts = value.split(/[-/\s]/);
              if (parts.length >= 3) {
                const day = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10);
                const year = parseInt(parts[2], 10);
                if (day && month && year) {
                  const parsed = new Date(year, month - 1, day);
                  if (!isNaN(parsed.getTime())) {
                    return parsed.toISOString();
                  }
                }
              }

              return null;
            };

            // Check for required fields
            const eventNo = getCellValue("eventNo");
            const eventType = getCellValue("eventType");

            // Skip empty rows (but log why)
            if (!eventNo && !eventType) {
              skippedRows.push({
                row: i,
                reason: "no eventNo/eventType",
                firstCells: row.slice(0, 5).map((c) => String(c || "").substring(0, 20)),
              });
              continue;
            }

            // Parse URL (returns null for non-URL values)
            const parseUrl = (value) => {
              if (!value) return null;
              if (value.toLowerCase() === "download") return null;
              if (value.startsWith("http://") || value.startsWith("https://")) {
                return value;
              }
              return null;
            };

            const rowData = {
              eventType: eventType,
              eventNo: eventNo,
              nitRefNo: getCellValue("nitRefNo"),
              eventTitle: getCellValue("eventTitle"),
              eventBank: getCellValue("eventBank"),
              eventBranch: getCellValue("eventBranch"),
              propertyCategory: getCellValue("propertyCategory"),
              propertySubCategory: getCellValue("propertySubCategory"),
              propertyDescription: getCellValue("propertyDescription"),
              borrowerName: getCellValue("borrowerName"),
              reservePrice: getNumericValue("reservePrice"),
              tenderFee: getNumericValue("tenderFee"),
              priceBid: getCellValue("priceBid"),
              bidIncrementValue: getNumericValue("bidIncrementValue"),
              autoExtensionTime: getCellValue("autoExtensionTime"),
              noOfAutoExtension: getCellValue("noOfAutoExtension"),
              dscRequired: getCellValue("dscRequired"),
              emdAmount: getNumericValue("emdAmount"),
              emdBankName: getCellValue("emdBankName"),
              emdAccountNo: getCellValue("emdAccountNo"),
              emdIfscCode: getCellValue("emdIfscCode"),
              pressReleaseDate: getDateValue("pressReleaseDate"),
              inspectionDateFrom: getDateValue("inspectionDateFrom"),
              inspectionDateTo: getDateValue("inspectionDateTo"),
              submissionLastDate: getDateValue("submissionLastDate"),
              offerOpeningDate: getDateValue("offerOpeningDate"),
              documentsRequired: getCellValue("documentsRequired"),
              paperPublishingUrl: parseUrl(getCellValue("paperPublishingUrl")),
              detailsOfBidderUrl: parseUrl(getCellValue("detailsOfBidderUrl")),
              declarationUrl: parseUrl(getCellValue("declarationUrl")),
            };

            parsedRows.push(rowData);
          } catch (rowError) {
            errors.push(`Row ${i + 1}: ${rowError.message}`);
          }
        }

        // Debug info - what headers were found
        const mappedHeaders = {};
        headers.forEach((header, index) => {
          const fieldName = columnMappings[header];
          if (fieldName) {
            mappedHeaders[header] = fieldName;
          }
        });

        const totalDataRows = jsonData.length - dataStartRow;

        res.status(200).json({
          success: true,
          fileName: fileName,
          totalRows: totalDataRows,
          successfulRows: parsedRows.length,
          data: parsedRows,
          errors: errors,
          debug: (() => {
            // Try to read raw cells for rows 2, 3, 4 to see if data exists
            const rawCellSamples = {};
            for (let r = 2; r <= 4; r++) {
              const rowCells = {};
              for (let c = 0; c < 5; c++) {
                const cellAddr = XLSX.utils.encode_cell({r: r, c: c});
                const cell = sheet[cellAddr];
                rowCells[cellAddr] = cell ? cell.v : "(empty)";
              }
              rawCellSamples[`row${r}`] = rowCells;
            }
            return {
              sheetNames: allSheetNames,
              selectedSheet: sheetName,
              sheetRange: sheet["!ref"],
              mergedCellsCount: merges.length,
              headerRowIndex: headerRowIndex,
              dataStartRow: dataStartRow,
              totalJsonRows: jsonData.length,
              sampleRow: jsonData.length > dataStartRow ? jsonData[dataStartRow] : null,
              row50Sample: jsonData.length > 50 ? jsonData[50] : null,
              row100Sample: jsonData.length > 100 ? jsonData[100] : null,
              skippedRowsSample: skippedRows.slice(0, 5),
              rawCellSamples: rawCellSamples,
            };
          })(),
        });
      } catch (error) {
        console.error("Parse error:", error);

        // Check for format issues
        const errorMessage = error.message.toLowerCase();
        let userMessage;

        if (errorMessage.includes("unsupported") ||
            errorMessage.includes("format") ||
            errorMessage.includes("invalid") ||
            errorMessage.includes("cfb")) {
          userMessage = "Invalid Excel format. Please ensure the file is a " +
            "valid .xls or .xlsx file.";
        } else {
          userMessage = `Failed to parse Excel file: ${error.message}`;
        }

        res.status(500).json({
          success: false,
          error: userMessage,
        });
      }
    });

// Keep the old conversion function for backward compatibility
exports.convertXlsToXlsx = functions
    .region("asia-south1")
    .runWith({
      timeoutSeconds: 60,
      memory: "256MB",
    })
    .https.onRequest(async (req, res) => {
      // Handle CORS
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // Handle preflight request
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // Only allow POST
      if (req.method !== "POST") {
        res.status(405).json({success: false, error: "Method not allowed"});
        return;
      }

      try {
        const data = req.body;

        if (!data || !data.fileBase64) {
          res.status(400).json({
            success: false,
            error: "Missing fileBase64 parameter",
          });
          return;
        }

        const fileName = data.fileName || "file.xls";
        const fileBuffer = Buffer.from(data.fileBase64, "base64");

        const workbook = XLSX.read(fileBuffer, {
          type: "buffer",
          cellDates: true,
          cellNF: true,
          cellStyles: true,
        });

        const xlsxBuffer = XLSX.write(workbook, {
          type: "buffer",
          bookType: "xlsx",
          cellDates: true,
        });

        const xlsxBase64 = xlsxBuffer.toString("base64");
        const newFileName = fileName.replace(/\.xls$/i, ".xlsx");

        res.status(200).json({
          success: true,
          xlsxBase64: xlsxBase64,
          fileName: newFileName,
        });
      } catch (error) {
        console.error("Conversion error:", error);
        res.status(500).json({
          success: false,
          error: `Failed to convert file: ${error.message}`,
        });
      }
    });

/**
 * HTTP Cloud Function to parse Vehicle Excel files (.xls or .xlsx)
 * Supports TATA Capital format with 60 columns
 * Returns parsed JSON data ready for import
 */
exports.parseVehicleExcelFile = functions
    .region("asia-south1")
    .runWith({
      timeoutSeconds: 120,
      memory: "512MB",
    })
    .https.onRequest(async (req, res) => {
      // Handle CORS
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      // Handle preflight request
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      // Only allow POST
      if (req.method !== "POST") {
        res.status(405).json({success: false, error: "Method not allowed"});
        return;
      }

      try {
        const data = req.body;

        // Validate input
        if (!data || !data.fileBase64) {
          res.status(400).json({
            success: false,
            error: "Missing fileBase64 parameter",
          });
          return;
        }

        const fileName = data.fileName || "file.xlsx";

        // Decode base64 to buffer
        const fileBuffer = Buffer.from(data.fileBase64, "base64");

        // Read the Excel file (supports both .xls and .xlsx)
        const workbook = XLSX.read(fileBuffer, {
          type: "buffer",
          cellDates: true,
          cellNF: true,
          cellText: true,
          raw: false,
        });

        // Check all sheets
        const allSheetNames = workbook.SheetNames;
        if (allSheetNames.length === 0) {
          res.status(400).json({
            success: false,
            error: "Excel file has no sheets",
          });
          return;
        }

        console.log("Vehicle Excel - Sheet names:", allSheetNames);

        // Try to find the sheet with the most data
        let bestSheet = null;
        let bestSheetName = allSheetNames[0];
        let maxRows = 0;

        for (const name of allSheetNames) {
          const s = workbook.Sheets[name];
          const range = s["!ref"];
          if (range) {
            const decoded = XLSX.utils.decode_range(range);
            const rows = decoded.e.r - decoded.s.r + 1;
            console.log(`Sheet "${name}": range=${range}, rows=${rows}`);
            if (rows > maxRows) {
              maxRows = rows;
              bestSheet = s;
              bestSheetName = name;
            }
          }
        }

        const sheet = bestSheet || workbook.Sheets[allSheetNames[0]];
        const sheetName = bestSheetName;

        // Convert to JSON with headers
        const jsonData = XLSX.utils.sheet_to_json(sheet, {
          header: 1,
          defval: "",
          raw: false,
          dateNF: "yyyy-mm-dd",
          blankrows: false,
        });

        if (jsonData.length < 2) {
          res.status(400).json({
            success: false,
            error: "Excel file has no data rows",
          });
          return;
        }

        // Find header row (look for vehicle-specific column names)
        const knownVehicleHeaders = [
          "make", "model", "registration number", "base price",
          "loan account number", "chassis no", "engine no",
        ];

        let headerRowIndex = 0;
        for (let i = 0; i < Math.min(jsonData.length, 10); i++) {
          const row = jsonData[i];
          if (!row || row.length === 0) continue;

          const rowText = row.map((c) =>
            String(c || "").toLowerCase().trim()
          ).join(" ");

          const matchCount = knownVehicleHeaders.filter((h) =>
            rowText.includes(h)
          ).length;

          if (matchCount >= 2) {
            headerRowIndex = i;
            break;
          }
        }

        // Get headers from the detected row
        const headers = jsonData[headerRowIndex].map((h) =>
          String(h || "").toLowerCase().trim(),
        );

        console.log("Vehicle Excel - Headers found:", headers.slice(0, 10));

        // TATA Capital column mappings
        const columnMappings = {
          // Contract/Account Number
          "loan account number/seller ref no": "contractNo",
          "loan account number": "contractNo",
          "loanaccountnumber/sellerrefno": "contractNo",
          "seller ref no": "contractNo",

          // Registration Number
          "registration number": "rcNo",
          "registrationnumber": "rcNo",
          "veh reg no": "rcNo",
          "vehicle registration number": "rcNo",

          // Vehicle details
          "make": "make",
          "model": "model",
          "variant": "variant",
          "asset desc": "assetDesc",
          "assetdesc": "assetDesc",
          "asset type": "assetType",
          "product": "product",

          // Engine & Chassis
          "engine no": "engineNo",
          "engineno": "engineNo",
          "chassis no": "chassisNo",
          "chassisno": "chassisNo",
          "rc chasi no": "rcChasiNo",
          "rc eng no": "rcEngNo",

          // Year of Manufacture
          "year of manufacture": "yom",
          "yearofmanufacture": "yom",
          "yom": "yom",
          "rc manu month year": "rcManuMonthYear",

          // Fuel Type
          "rc fuel desc": "fuelType",
          "rcfueldesc": "fuelType",
          "fuel type": "fuelType",

          // Yard Info
          "yard name": "yardName",
          "yardname": "yardName",
          "yard address": "yardAddress",
          "city/location": "yardCity",
          "citylocation": "yardCity",
          "city": "yardCity",
          "location": "yardCity",
          "state": "yardState",
          "region": "region",
          "branch name": "branchName",

          // Pricing
          "base price": "basePrice",
          "baseprice": "basePrice",
          "bid start price": "bidStartPrice",
          "bid increment": "bidIncrement",
          "bidincrement": "bidIncrement",
          "bid multiples": "multipleAmount",
          "bidmultiples": "multipleAmount",
          "no. of bids per user": "bidsPerUser",

          // Parking Charges
          "parking charges/day": "parkingChargesPerDay",
          "expected parking charges till current month end": "expectedParkingCharges",

          // Contact Info
          "yard contact person name": "contactPerson",
          "yardcontactpersonname": "contactPerson",
          "yard contact number": "contactNumber",
          "yardcontactnumber": "contactNumber",
          "borrower name": "borrowerName",

          // Remarks
          "special remarks(if any)": "remark",
          "specialremarks(ifany)": "remark",
          "special remarks": "remark",

          // RC Status
          "rc status": "rcStatus",
          "rcstatus": "rcStatus",

          // Dates
          "repo date": "repoDate",
          "repodate": "repoDate",
          "event start date and time": "startDate",
          "eventstartdateandtime": "startDate",
          "auction end datetime": "endDate",
          "auctionenddatetime": "endDate",

          // RC Details
          "rc regn date": "rcRegnDate",
          "rc regn upto": "rcRegnUpto",
          "rc owner sr": "rcOwnerSr",
          "rc vh class desc": "rcVhClassDesc",
          "rc maker desc": "rcMakerDesc",
          "rc maker model": "rcMakerModel",
          "rc body type desc": "rcBodyTypeDesc",
          "rc norms desc": "rcNormsDesc",
          "rc fit upto": "rcFitUpto",
          "rc np upto": "rcNpUpto",
          "rc tax upto": "rcTaxUpto",
          "rc financer": "rcFinancer",
          "rc insurance upto": "rcInsuranceUpto",
          "rc status as on": "rcStatusAsOn",
          "rc ncrb status": "rcNcrbStatus",
          "rc blacklist status": "rcBlacklistStatus",
          "rc permit valid upto": "rcPermitValidUpto",
          "rc pucc upto": "rcPuccUpto",
          "tax o/s amount": "taxOutstandingAmount",
          "challan pending amount": "challanPendingAmount",

          // Images
          "images": "images",

          // Event Info
          "record id": "recordId",
          "event id": "eventId",
          "event name": "eventName",
        };

        // Create column index map
        const columnIndexMap = {};
        headers.forEach((header, index) => {
          const fieldName = columnMappings[header];
          if (fieldName) {
            columnIndexMap[fieldName] = index;
          }
        });

        console.log("Vehicle Excel - Mapped columns:", Object.keys(columnIndexMap));

        // Parse data rows
        const parsedRows = [];
        const errors = [];
        const dataStartRow = headerRowIndex + 1;

        for (let i = dataStartRow; i < jsonData.length; i++) {
          const row = jsonData[i];

          if (!row || row.length === 0) continue;

          try {
            // Helper functions
            const getCellValue = (fieldName, defaultValue = "") => {
              const index = columnIndexMap[fieldName];
              if (index === undefined || index >= row.length) return defaultValue;
              const value = row[index];
              if (value === null || value === undefined) return defaultValue;
              return String(value).trim();
            };

            const getNumericValue = (fieldName, defaultValue = 0) => {
              const value = getCellValue(fieldName);
              if (!value) return defaultValue;
              const cleaned = value.replace(/[,\s]/g, "");
              const num = parseFloat(cleaned);
              return isNaN(num) ? defaultValue : num;
            };

            const getIntValue = (fieldName, defaultValue = 0) => {
              const value = getCellValue(fieldName);
              if (!value) return defaultValue;
              const cleaned = value.replace(/[,\s]/g, "");
              const num = parseInt(cleaned, 10);
              return isNaN(num) ? defaultValue : num;
            };

            const getDateValue = (fieldName) => {
              const value = getCellValue(fieldName);
              if (!value) return null;

              // Try parsing as date
              const date = new Date(value);
              if (!isNaN(date.getTime())) {
                return date.toISOString();
              }

              // Try dd-mm-yyyy HH:mm:ss format
              const dateTimeMatch = value.match(/^(\d{2})-(\d{2})-(\d{4})\s+(\d{2}):(\d{2}):(\d{2})$/);
              if (dateTimeMatch) {
                const [, day, month, year, hour, min, sec] = dateTimeMatch;
                const parsed = new Date(year, month - 1, day, hour, min, sec);
                if (!isNaN(parsed.getTime())) {
                  return parsed.toISOString();
                }
              }

              // Try dd-mm-yyyy format
              const dateMatch = value.match(/^(\d{2})-(\d{2})-(\d{4})$/);
              if (dateMatch) {
                const [, day, month, year] = dateMatch;
                const parsed = new Date(year, month - 1, day);
                if (!isNaN(parsed.getTime())) {
                  return parsed.toISOString();
                }
              }

              return null;
            };

            const getBoolValue = (fieldName, defaultValue = false) => {
              const value = getCellValue(fieldName).toLowerCase();
              if (!value) return defaultValue;
              return value === "yes" || value === "true" || value === "1" ||
                     value === "available" || value === "y";
            };

            // Parse images (JSON array format)
            const parseImages = (fieldName) => {
              const value = getCellValue(fieldName);
              if (!value) return [];
              try {
                const parsed = JSON.parse(value);
                if (Array.isArray(parsed)) {
                  return parsed.map((url) => String(url).trim()).filter((url) => url);
                }
                return [value];
              } catch (e) {
                // If not JSON, treat as single URL
                if (value.startsWith("http")) {
                  return [value];
                }
                return [];
              }
            };

            // Check for required fields
            const contractNo = getCellValue("contractNo");
            const rcNo = getCellValue("rcNo");
            const make = getCellValue("make");

            // Skip if missing required identifiers
            if (!contractNo && !rcNo) {
              continue;
            }

            if (!make) {
              continue;
            }

            const rowData = {
              contractNo: contractNo,
              rcNo: rcNo,
              make: make,
              model: getCellValue("model"),
              variant: getCellValue("variant"),
              assetDesc: getCellValue("assetDesc"),
              assetType: getCellValue("assetType"),
              product: getCellValue("product"),
              engineNo: getCellValue("engineNo"),
              chassisNo: getCellValue("chassisNo"),
              yom: getIntValue("yom"),
              fuelType: getCellValue("fuelType"),
              yardName: getCellValue("yardName"),
              yardAddress: getCellValue("yardAddress"),
              yardCity: getCellValue("yardCity"),
              yardState: getCellValue("yardState"),
              region: getCellValue("region"),
              branchName: getCellValue("branchName"),
              basePrice: getNumericValue("basePrice"),
              bidStartPrice: getNumericValue("bidStartPrice"),
              bidIncrement: getNumericValue("bidIncrement"),
              multipleAmount: getNumericValue("multipleAmount"),
              bidsPerUser: getIntValue("bidsPerUser"),
              parkingChargesPerDay: getNumericValue("parkingChargesPerDay"),
              expectedParkingCharges: getNumericValue("expectedParkingCharges"),
              contactPerson: getCellValue("contactPerson"),
              contactNumber: getCellValue("contactNumber"),
              borrowerName: getCellValue("borrowerName"),
              remark: getCellValue("remark"),
              rcStatus: getCellValue("rcStatus"),
              rcAvailable: getBoolValue("rcStatus") ||
                           getCellValue("rcStatus").toLowerCase().includes("available"),
              repoDate: getDateValue("repoDate"),
              startDate: getDateValue("startDate"),
              endDate: getDateValue("endDate"),
              images: parseImages("images"),
              // Additional RC details
              rcRegnDate: getCellValue("rcRegnDate"),
              rcRegnUpto: getCellValue("rcRegnUpto"),
              rcOwnerSr: getCellValue("rcOwnerSr"),
              rcVhClassDesc: getCellValue("rcVhClassDesc"),
              rcMakerDesc: getCellValue("rcMakerDesc"),
              rcMakerModel: getCellValue("rcMakerModel"),
              rcBodyTypeDesc: getCellValue("rcBodyTypeDesc"),
              rcFuelDesc: getCellValue("fuelType"),
              rcNormsDesc: getCellValue("rcNormsDesc"),
              rcFitUpto: getCellValue("rcFitUpto"),
              rcNpUpto: getCellValue("rcNpUpto"),
              rcTaxUpto: getCellValue("rcTaxUpto"),
              rcFinancer: getCellValue("rcFinancer"),
              rcInsuranceUpto: getCellValue("rcInsuranceUpto"),
              rcManuMonthYear: getCellValue("rcManuMonthYear"),
              rcStatusAsOn: getCellValue("rcStatusAsOn"),
              rcNcrbStatus: getCellValue("rcNcrbStatus"),
              rcBlacklistStatus: getCellValue("rcBlacklistStatus"),
              rcPermitValidUpto: getCellValue("rcPermitValidUpto"),
              rcPuccUpto: getCellValue("rcPuccUpto"),
              taxOutstandingAmount: getNumericValue("taxOutstandingAmount"),
              challanPendingAmount: getNumericValue("challanPendingAmount"),
              // Event info
              recordId: getCellValue("recordId"),
              eventId: getCellValue("eventId"),
              eventName: getCellValue("eventName"),
            };

            parsedRows.push(rowData);
          } catch (rowError) {
            errors.push(`Row ${i + 1}: ${rowError.message}`);
          }
        }

        const totalDataRows = jsonData.length - dataStartRow;

        console.log(`Vehicle Excel - Parsed ${parsedRows.length}/${totalDataRows} rows`);

        res.status(200).json({
          success: true,
          fileName: fileName,
          totalRows: totalDataRows,
          successfulRows: parsedRows.length,
          data: parsedRows,
          errors: errors,
          debug: {
            sheetNames: allSheetNames,
            selectedSheet: sheetName,
            headerRowIndex: headerRowIndex,
            dataStartRow: dataStartRow,
            totalJsonRows: jsonData.length,
            mappedColumns: Object.keys(columnIndexMap),
            sampleHeaders: headers.slice(0, 15),
          },
        });
      } catch (error) {
        console.error("Vehicle Excel parse error:", error);

        const errorMessage = error.message.toLowerCase();
        let userMessage;

        if (errorMessage.includes("unsupported") ||
            errorMessage.includes("format") ||
            errorMessage.includes("invalid") ||
            errorMessage.includes("cfb")) {
          userMessage = "Invalid Excel format. Please ensure the file is a " +
            "valid .xls or .xlsx file.";
        } else {
          userMessage = `Failed to parse Excel file: ${error.message}`;
        }

        res.status(500).json({
          success: false,
          error: userMessage,
        });
      }
    });

/**
 * Scheduled Cloud Function to automatically update auction statuses
 * Runs every 5 minutes
 * - Moves "upcoming" auctions to "live" when startDate passes
 * - Moves "live" auctions to "ended" when endDate passes
 */
exports.updateAuctionStatuses = functions
    .region("asia-south1")
    .runWith({
      timeoutSeconds: 120,
      memory: "256MB",
    })
    .pubsub.schedule("every 5 minutes")
    .timeZone("Asia/Kolkata")
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const nowDate = now.toDate();

      console.log(`[AuctionStatusUpdate] Running at ${nowDate.toISOString()}`);

      let upcomingToLive = 0;
      let liveToEnded = 0;

      try {
        // Get all auctions that need status update
        const auctionsRef = db.collection("auctions");

        // 1. Find "upcoming" auctions where startDate has passed
        const upcomingQuery = await auctionsRef
            .where("status", "==", "upcoming")
            .where("startDate", "<=", now)
            .get();

        console.log(`[AuctionStatusUpdate] Found ${upcomingQuery.size} upcoming auctions to activate`);

        // Update upcoming -> live
        const upcomingBatch = db.batch();
        upcomingQuery.docs.forEach((doc) => {
          const data = doc.data();
          const endDate = data.endDate?.toDate();

          // Check if auction should go directly to "ended" (if endDate also passed)
          if (endDate && endDate <= nowDate) {
            upcomingBatch.update(doc.ref, {
              status: "ended",
              updatedAt: now,
            });
            liveToEnded++;
            console.log(`[AuctionStatusUpdate] Auction ${doc.id} (${data.name}): upcoming -> ended (already expired)`);
          } else {
            upcomingBatch.update(doc.ref, {
              status: "live",
              updatedAt: now,
            });
            upcomingToLive++;
            console.log(`[AuctionStatusUpdate] Auction ${doc.id} (${data.name}): upcoming -> live`);
          }
        });

        if (upcomingQuery.size > 0) {
          await upcomingBatch.commit();
        }

        // 2. Find "live" auctions where endDate has passed
        const liveQuery = await auctionsRef
            .where("status", "==", "live")
            .where("endDate", "<=", now)
            .get();

        console.log(`[AuctionStatusUpdate] Found ${liveQuery.size} live auctions to end`);

        // Update live -> ended
        const liveBatch = db.batch();
        liveQuery.docs.forEach((doc) => {
          const data = doc.data();
          liveBatch.update(doc.ref, {
            status: "ended",
            updatedAt: now,
          });
          liveToEnded++;
          console.log(`[AuctionStatusUpdate] Auction ${doc.id} (${data.name}): live -> ended`);
        });

        if (liveQuery.size > 0) {
          await liveBatch.commit();
        }

        const summary = `Updated ${upcomingToLive} upcoming->live, ${liveToEnded} live->ended`;
        console.log(`[AuctionStatusUpdate] Complete: ${summary}`);

        return {
          success: true,
          upcomingToLive,
          liveToEnded,
          timestamp: nowDate.toISOString(),
        };
      } catch (error) {
        console.error("[AuctionStatusUpdate] Error:", error);

        return {
          success: false,
          error: error.message,
          upcomingToLive,
          liveToEnded,
        };
      }
    });

/**
 * HTTP endpoint to manually trigger auction status update
 * Useful for testing or forcing an immediate update
 */
exports.triggerAuctionStatusUpdate = functions
    .region("asia-south1")
    .runWith({
      timeoutSeconds: 120,
      memory: "256MB",
    })
    .https.onRequest(async (req, res) => {
      // Handle CORS
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type");

      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      const now = admin.firestore.Timestamp.now();
      const nowDate = now.toDate();

      console.log(`[ManualAuctionStatusUpdate] Triggered at ${nowDate.toISOString()}`);

      let upcomingToLive = 0;
      let liveToEnded = 0;
      const updatedAuctions = [];

      try {
        const auctionsRef = db.collection("auctions");

        // 1. Update upcoming -> live
        const upcomingQuery = await auctionsRef
            .where("status", "==", "upcoming")
            .where("startDate", "<=", now)
            .get();

        for (const doc of upcomingQuery.docs) {
          const data = doc.data();
          const endDate = data.endDate?.toDate();

          if (endDate && endDate <= nowDate) {
            await doc.ref.update({
              status: "ended",
              updatedAt: now,
            });
            liveToEnded++;
            updatedAuctions.push({
              id: doc.id,
              name: data.name,
              transition: "upcoming -> ended",
            });
          } else {
            await doc.ref.update({
              status: "live",
              updatedAt: now,
            });
            upcomingToLive++;
            updatedAuctions.push({
              id: doc.id,
              name: data.name,
              transition: "upcoming -> live",
            });
          }
        }

        // 2. Update live -> ended
        const liveQuery = await auctionsRef
            .where("status", "==", "live")
            .where("endDate", "<=", now)
            .get();

        for (const doc of liveQuery.docs) {
          const data = doc.data();
          await doc.ref.update({
            status: "ended",
            updatedAt: now,
          });
          liveToEnded++;
          updatedAuctions.push({
            id: doc.id,
            name: data.name,
            transition: "live -> ended",
          });
        }

        res.status(200).json({
          success: true,
          message: `Updated ${upcomingToLive + liveToEnded} auctions`,
          upcomingToLive,
          liveToEnded,
          updatedAuctions,
          timestamp: nowDate.toISOString(),
        });
      } catch (error) {
        console.error("[ManualAuctionStatusUpdate] Error:", error);
        res.status(500).json({
          success: false,
          error: error.message,
        });
      }
    });
