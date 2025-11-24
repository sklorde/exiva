/**
 * Test script to verify improved QR endpoint with MIME type extraction
 */

const express = require('express');
const qrcode = require('qrcode');

const app = express();
const PORT = 3003;

let qrCodeData = null;
let isAuthenticated = false;

// Generate a test QR code on startup
async function generateTestQR() {
    try {
        // Generate a test QR code (defaults to PNG)
        qrCodeData = await qrcode.toDataURL('https://example.com/test-qr');
        console.log('Test QR code generated:', qrCodeData.substring(0, 50) + '...');
    } catch (error) {
        console.error('Error generating QR code:', error.message);
    }
}

/**
 * Get QR code for authentication - returns image with proper MIME type handling
 */
app.get('/qr', async (req, res) => {
    if (isAuthenticated) {
        return res.status(200).send('Already authenticated. No QR code needed.');
    }

    if (!qrCodeData) {
        return res.status(404).send('QR code not available yet. Please wait for the QR code to be generated.');
    }

    try {
        // Extract MIME type and base64 data from data URL (format: data:image/png;base64,...)
        const matches = qrCodeData.match(/^data:([^;]+);base64,(.+)$/);
        
        if (!matches) {
            console.error('Invalid QR code data URL format');
            return res.status(500).send('Invalid QR code data format');
        }
        
        const mimeType = matches[1];
        const base64Data = matches[2];
        const imageBuffer = Buffer.from(base64Data, 'base64');
        
        console.log(`Sending QR code with MIME type: ${mimeType}, size: ${imageBuffer.length} bytes`);
        
        // Set content type and send image
        res.setHeader('Content-Type', mimeType);
        res.setHeader('Content-Length', imageBuffer.length);
        res.send(imageBuffer);
    } catch (error) {
        console.error(`Error sending QR code image: ${error.message}`);
        res.status(500).send('Error generating QR code image');
    }
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

// Start server
app.listen(PORT, '0.0.0.0', async () => {
    console.log(`Test server listening on port ${PORT}`);
    await generateTestQR();
    console.log('Server ready for testing');
});
