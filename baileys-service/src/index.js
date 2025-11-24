/**
 * Baileys WhatsApp Web API Service
 * This service provides WhatsApp messaging capabilities using Baileys library
 */

const express = require('express');
const makeWASocket = require('@whiskeysockets/baileys').default;
const {
    DisconnectReason,
    useMultiFileAuthState,
    makeInMemoryStore,
    fetchLatestBaileysVersion
} = require('@whiskeysockets/baileys');
const P = require('pino');
const qrcode = require('qrcode');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// Logger configuration
const logger = P({ level: process.env.LOG_LEVEL || 'info' });

// Store for sessions
let sock = null;
let qrCodeData = null;
let isAuthenticated = false;
let connectionRetries = 0;
const MAX_RETRIES = parseInt(process.env.MAX_CONNECTION_RETRIES) || 10;
const RETRY_DELAY_MS = parseInt(process.env.RETRY_DELAY_MS) || 3000;
const MAX_RETRY_BACKOFF_MS = parseInt(process.env.MAX_RETRY_BACKOFF_MS) || 30000;

/**
 * Initialize WhatsApp connection
 */
async function connectToWhatsApp() {
    try {
        const { state, saveCreds } = await useMultiFileAuthState('/app/auth_info');
        const { version } = await fetchLatestBaileysVersion();

        logger.info(`Using Baileys version: ${version.join('.')}`);

        sock = makeWASocket({
            version,
            logger,
            auth: state,
            // Add browser config
            browser: ['WIFE WhatsApp Service', 'Chrome', '1.0.0']
        });

        // Save credentials when updated
        sock.ev.on('creds.update', saveCreds);

        // Connection state updates
        sock.ev.on('connection.update', async (update) => {
            const { connection, lastDisconnect, qr } = update;

            if (qr) {
                try {
                    logger.info('QR Code received, generating data URL...');
                    qrCodeData = await qrcode.toDataURL(qr);
                    isAuthenticated = false;
                    logger.info('QR Code data URL generated successfully');
                } catch (error) {
                    logger.error(`Error generating QR code data URL: ${error.message}`);
                }
            }

            if (connection === 'close') {
                const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
                const statusCode = lastDisconnect?.error?.output?.statusCode;
                logger.info(`Connection closed with status code: ${statusCode}, reconnecting: ${shouldReconnect}`);
                
                if (lastDisconnect?.error) {
                    logger.error(`Connection error: ${lastDisconnect.error.message}`);
                }
                
                isAuthenticated = false;
                
                if (shouldReconnect) {
                    connectionRetries++;
                    
                    if (connectionRetries > MAX_RETRIES) {
                        logger.warn(`Max retries (${MAX_RETRIES}) reached. Waiting ${MAX_RETRY_BACKOFF_MS}ms before trying again...`);
                        connectionRetries = 0; // Reset counter
                        setTimeout(() => connectToWhatsApp(), MAX_RETRY_BACKOFF_MS);
                    } else {
                        // Add a small delay before reconnecting to avoid rapid reconnection loops
                        logger.info(`Retry attempt ${connectionRetries}/${MAX_RETRIES} in ${RETRY_DELAY_MS}ms...`);
                        setTimeout(() => connectToWhatsApp(), RETRY_DELAY_MS);
                    }
                }
            } else if (connection === 'open') {
                logger.info('WhatsApp connection opened successfully');
                isAuthenticated = true;
                qrCodeData = null;
                connectionRetries = 0; // Reset retry counter on successful connection
            }
        });

        // Handle incoming messages
        sock.ev.on('messages.upsert', async ({ messages, type }) => {
            logger.info(`Received ${messages.length} messages of type: ${type}`);
            
            for (const message of messages) {
                if (!message.key.fromMe && message.message) {
                    logger.info(`Message from ${message.key.remoteJid}: ${JSON.stringify(message.message)}`);
                }
            }
        });

    } catch (error) {
        logger.error(`Error connecting to WhatsApp: ${error.message}`);
        // Retry connection after 5 seconds
        setTimeout(connectToWhatsApp, 5000);
    }
}

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'Baileys WhatsApp Service',
        authenticated: isAuthenticated,
        timestamp: new Date().toISOString()
    });
});

/**
 * Get QR code for authentication
 */
app.get('/qr', async (req, res) => {
    if (isAuthenticated) {
        return res.status(200).send('Already authenticated. No QR code needed.');
    }

    if (!qrCodeData) {
        return res.status(404).send('QR code not available yet. Please wait for the QR code to be generated.');
    }

    try {
        // Extract base64 data from data URL (format: data:image/png;base64,...)
        const base64Data = qrCodeData.replace(/^data:image\/png;base64,/, '');
        const imageBuffer = Buffer.from(base64Data, 'base64');
        
        // Set content type and send image
        res.setHeader('Content-Type', 'image/png');
        res.setHeader('Content-Length', imageBuffer.length);
        res.send(imageBuffer);
    } catch (error) {
        logger.error(`Error sending QR code image: ${error.message}`);
        res.status(500).send('Error generating QR code image');
    }
});

/**
 * Get authentication status
 */
app.get('/status', (req, res) => {
    res.json({
        authenticated: isAuthenticated,
        connected: sock?.user ? true : false,
        user: sock?.user || null
    });
});

/**
 * Send a text message
 */
app.post('/send-message', async (req, res) => {
    try {
        if (!isAuthenticated) {
            return res.status(401).json({
                error: 'Not authenticated',
                message: 'Please scan QR code first'
            });
        }

        const { number, message } = req.body;

        if (!number || !message) {
            return res.status(400).json({
                error: 'Missing parameters',
                message: 'Number and message are required'
            });
        }

        // Format number to WhatsApp JID
        const jid = number.includes('@s.whatsapp.net') 
            ? number 
            : `${number}@s.whatsapp.net`;

        await sock.sendMessage(jid, { text: message });

        res.json({
            success: true,
            message: 'Message sent successfully',
            to: jid
        });

    } catch (error) {
        logger.error(`Error sending message: ${error.message}`);
        res.status(500).json({
            error: 'Failed to send message',
            message: error.message
        });
    }
});

/**
 * Logout from WhatsApp
 */
app.post('/logout', async (req, res) => {
    try {
        if (sock) {
            await sock.logout();
            isAuthenticated = false;
            qrCodeData = null;
        }

        res.json({
            success: true,
            message: 'Logged out successfully'
        });
    } catch (error) {
        logger.error(`Error logging out: ${error.message}`);
        res.status(500).json({
            error: 'Failed to logout',
            message: error.message
        });
    }
});

/**
 * Root endpoint
 */
app.get('/', (req, res) => {
    res.json({
        service: 'Baileys WhatsApp Service',
        version: '1.0.0',
        endpoints: {
            health: 'GET /health',
            qr: 'GET /qr',
            status: 'GET /status',
            sendMessage: 'POST /send-message',
            logout: 'POST /logout'
        }
    });
});

// Start server
app.listen(PORT, HOST, () => {
    logger.info(`Baileys service listening on ${HOST}:${PORT}`);
    connectToWhatsApp();
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    logger.info('SIGTERM received, closing connections...');
    if (sock) {
        await sock.end();
    }
    process.exit(0);
});

process.on('SIGINT', async () => {
    logger.info('SIGINT received, closing connections...');
    if (sock) {
        await sock.end();
    }
    process.exit(0);
});
