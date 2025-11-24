const fetch = require('node-fetch');
const FormData = require('form-data');
const { downloadContentFromMessage } = require('@whiskeysockets/baileys');

const WIFE_API_URL = process.env.WIFE_API_URL || 'http://localhost:8000';
const WIFE_API_TOKEN = process.env.WIFE_API_TOKEN || '';
const MONITORED_CHATS_RAW = process.env.MONITORED_CHATS || '';
const MONITOR_BY_JID_ONLY = (process.env.MONITOR_BY_JID_ONLY || 'true').toLowerCase() === 'true';

const monitoredSet = new Set(
  MONITORED_CHATS_RAW
    .split(',')
    .map(s => s.trim())
    .filter(Boolean)
    .map(s => s.toLowerCase())
);

function normalizeId(s) {
  return s ? String(s).trim().toLowerCase() : '';
}

function isChatMonitored(msg) {
  if (!msg || !msg.key) return false;

  const remoteJid = normalizeId(msg.key.remoteJid);
  if (monitoredSet.has(remoteJid)) return true;

  if (!MONITOR_BY_JID_ONLY) {
    const pushName = normalizeId(msg.pushName || (msg.message && msg.message.pushName) || '');
    if (pushName && monitoredSet.has(pushName)) return true;

    const conversation = normalizeId(msg.message?.conversation || '');
    if (conversation && monitoredSet.has(conversation)) return true;
  }

  return false;
}

async function bufferFromMessageStream(message, type = 'image') {
  const stream = await downloadContentFromMessage(message, type);
  const chunks = [];
  for await (const chunk of stream) chunks.push(Buffer.from(chunk));
  return Buffer.concat(chunks);
}

function extractLocationFromMessage(messageText, defaultLocation = 'whatsapp') {
  if (!messageText) return defaultLocation;
  const m = messageText.match(/loc=([^\s]+)/i);
  if (m) return m[1];
  return defaultLocation;
}

async function handleIncomingMessage(conn, msg) {
  try {
    if (!msg) return;
    if (msg.key && msg.key.fromMe) return; // ignore messages from the bot itself

    console.debug('Incoming message:', {
      remoteJid: msg.key?.remoteJid,
      pushName: msg.pushName || msg.message?.pushName,
      hasMessage: !!msg.message
    });

    if (!isChatMonitored(msg)) return; // not monitored

    const message = msg.message;
    if (!message) return;

    const media = message.imageMessage || message.documentMessage;
    if (!media) return;

    const mimetype = media.mimetype || 'image/jpeg';

    const buffer = await bufferFromMessageStream(media, 'image');

    const text = message.conversation || message.extendedTextMessage?.text || '';
    const location = extractLocationFromMessage(text, 'from_whatsapp');

    const form = new FormData();
    form.append('file', buffer, {
      filename: 'whatsapp_photo.jpg',
      contentType: mimetype
    });
    form.append('location', location);

    const headers = form.getHeaders();
    if (WIFE_API_TOKEN) headers['Authorization'] = `Bearer ${WIFE_API_TOKEN}`;

    const res = await fetch(`${WIFE_API_URL}/api/detect`, {
      method: 'POST',
      body: form,
      headers
    });

    if (!res.ok) {
      const textBody = await res.text();
      console.error('Erro ao enviar para WIFE:', res.status, textBody);
      return;
    }

    const result = await res.json();
    console.info('WIFE detect response:', result);

    const summary = `Detectei ${result.objects_detected} objeto(s):\n` +
      (result.detections && result.detections.length
        ? result.detections.map(d => `- ${d.name} (${(d.confidence*100).toFixed(1)}%)`).join('\n')
        : '- nenhum objeto identificado');

    await conn.sendMessage(msg.key.remoteJid, { text: summary });

  } catch (err) {
    console.error('Erro no handleIncomingMessage:', err);
  }
}

module.exports = {
  handleIncomingMessage,
  isChatMonitored
};
