const functions = require("firebase-functions");
const XLSX = require("xlsx");

/**
 * Cloud Function to convert .xls files to .xlsx format
 * Accepts base64 encoded .xls file and returns base64 encoded .xlsx file
 */
exports.convertXlsToXlsx = functions
    .region("asia-south1") // Mumbai region for lower latency in India
    .runWith({
      timeoutSeconds: 60,
      memory: "256MB",
    })
    .https.onCall(async (data, context) => {
      try {
        // Validate input
        if (!data || !data.fileBase64) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "Missing fileBase64 parameter",
          );
        }

        const fileName = data.fileName || "file.xls";

        // Check if the file is actually a .xls file
        if (!fileName.toLowerCase().endsWith(".xls")) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "File must be a .xls file",
          );
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

        return {
          success: true,
          xlsxBase64: xlsxBase64,
          fileName: newFileName,
          originalSize: xlsBuffer.length,
          convertedSize: xlsxBuffer.length,
        };
      } catch (error) {
        console.error("Conversion error:", error);

        if (error instanceof functions.https.HttpsError) {
          throw error;
        }

        throw new functions.https.HttpsError(
            "internal",
            `Failed to convert file: ${error.message}`,
        );
      }
    });
