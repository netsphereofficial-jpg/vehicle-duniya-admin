const functions = require("firebase-functions");
const XLSX = require("xlsx");

/**
 * HTTP Cloud Function to convert .xls files to .xlsx format
 * Accepts base64 encoded .xls file and returns base64 encoded .xlsx file
 */
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

        // Validate input
        if (!data || !data.fileBase64) {
          res.status(400).json({
            success: false,
            error: "Missing fileBase64 parameter",
          });
          return;
        }

        const fileName = data.fileName || "file.xls";

        // Check if the file is actually a .xls file
        if (!fileName.toLowerCase().endsWith(".xls") ||
            fileName.toLowerCase().endsWith(".xlsx")) {
          res.status(400).json({
            success: false,
            error: "File must be a .xls file (not .xlsx)",
          });
          return;
        }

        // Decode base64 to buffer
        const xlsBuffer = Buffer.from(data.fileBase64, "base64");

        // Read the .xls file
        const workbook = XLSX.read(xlsBuffer, {
          type: "buffer",
          cellDates: true,
          cellNF: true,
          cellStyles: true,
        });

        // Convert to .xlsx format
        const xlsxBuffer = XLSX.write(workbook, {
          type: "buffer",
          bookType: "xlsx",
          cellDates: true,
        });

        // Return base64 encoded .xlsx
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
