/**
 * Test script to verify enhanced validation in QR endpoint
 */

const express = require('express');
const qrcode = require('qrcode');

const app = express();
const PORT = 3004;

let qrCodeData = null;
let isAuthenticated = false;

// Generate a test QR code on startup
async function generateTestQR() {
    try {
        qrCodeData = await qrcode.toDataURL('https://example.com/test-validation');
        console.log('Test QR code generated');
    } catch (error) {
        console.error('Error generating QR code:', error.message);
    }
}

const P = require('pino');
const logger = P({ level: 'info' });

/**
 * Get QR code for authentication - with enhanced validation
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
            logger.error(`Invalid QR code data URL format: ${qrCodeData.substring(0, 50)}...`);
            return res.status(500).send('Invalid QR code data format');
        }
        
        const mimeType = matches[1];
        const base64Data = matches[2];
        
        // Validate MIME type to prevent header injection
        const allowedMimeTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
        if (!allowedMimeTypes.includes(mimeType)) {
            logger.error(`Invalid or unsupported MIME type: ${mimeType}`);
            return res.status(500).send('Unsupported image format');
        }
        
        // Validate base64 data format
        if (!/^[A-Za-z0-9+/]+=*$/.test(base64Data)) {
            logger.error('Invalid base64 data in QR code data URL');
            return res.status(500).send('Invalid QR code data format');
        }
        
        const imageBuffer = Buffer.from(base64Data, 'base64');
        
        // Verify buffer was created successfully
        if (imageBuffer.length === 0) {
            logger.error('Failed to create image buffer from base64 data');
            return res.status(500).send('Failed to generate QR code image');
        }
        
        // Set content type and send image
        res.setHeader('Content-Type', mimeType);
        res.setHeader('Content-Length', imageBuffer.length);
        res.send(imageBuffer);
    } catch (error) {
        logger.error(`Error sending QR code image: ${error.message}`);
        res.status(500).send('Error generating QR code image');
    }
});

// Test endpoints for malicious scenarios
app.get('/test-malicious-mime', (req, res) => {
    qrCodeData = 'data:text/html;base64,PHNjcmlwdD5hbGVydCgneHNzJyk8L3NjcmlwdD4=';
    res.send('Set malicious MIME type');
});

app.get('/test-invalid-base64', (req, res) => {
    qrCodeData = 'data:image/png;base64,!!!invalid!!!';
    res.send('Set invalid base64');
});

app.get('/reset', async (req, res) => {
    await generateTestQR();
    res.send('Reset to valid QR code');
});

// Start server
app.listen(PORT, '0.0.0.0', async () => {
    console.log(`Test server listening on port ${PORT}`);
    await generateTestQR();
    console.log('Server ready for testing');
});
