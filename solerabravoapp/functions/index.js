/**
 * Cloud Function: revenuecatWebhook
 *
 * Recibe los eventos de RevenueCat y actualiza el campo `isPremium`
 * en el documento del usuario en Firestore.
 *
 * CONFIGURACIÓN:
 * 1. Despliega con:  firebase deploy --only functions
 * 2. En RevenueCat Dashboard → Project Settings → Webhooks:
 *    - URL: https://<region>-<project-id>.cloudfunctions.net/revenuecatWebhook
 *    - Authorization header: el valor de REVENUECAT_WEBHOOK_KEY (ver paso 3)
 * 3. Guarda la clave secreta con:
 *    firebase functions:config:set revenuecat.webhook_key="TU_CLAVE_SECRETA"
 */

const functions  = require('firebase-functions');
const admin      = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

// Eventos que activan el estado Premium
const PREMIUM_EVENTS = new Set([
  'INITIAL_PURCHASE',    // Primera compra
  'RENEWAL',             // Renovación automática
  'PRODUCT_CHANGE',      // Cambio de plan
  'RESUBSCRIBE',         // Re-suscripción tras cancelar
  'TRIAL_CONVERTED',     // Trial convertido en pago
  'UNCANCELLATION',      // Usuario revirtió la cancelación
]);

// Eventos que desactivan el estado Premium
const NON_PREMIUM_EVENTS = new Set([
  'CANCELLATION',        // Cancelación (puede seguir activo hasta expiración)
  'EXPIRATION',          // Suscripción expirada definitivamente
  'BILLING_ISSUE',       // Problema de pago (opcional: podrías mantener acceso unos días)
  'SUBSCRIPTION_PAUSED', // Solo en Android
]);

exports.revenuecatWebhook = functions.https.onRequest(async (req, res) => {
  // Solo acepta POST
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  // ── Verificar autorización ─────────────────────────────────────────────────
  const authHeader    = req.headers['authorization'];
  const expectedKey   = functions.config().revenuecat?.webhook_key;

  if (!expectedKey) {
    functions.logger.error('revenuecat.webhook_key no configurado');
    return res.status(500).send('Server misconfiguration');
  }

  if (authHeader !== expectedKey) {
    functions.logger.warn('Webhook recibido con clave inválida');
    return res.status(401).send('Unauthorized');
  }

  // ── Parsear evento ─────────────────────────────────────────────────────────
  const { event } = req.body;

  if (!event) {
    return res.status(400).send('Missing event body');
  }

  const { type, app_user_id: uid, product_id, environment } = event;

  functions.logger.info(`Webhook RevenueCat: type=${type}, uid=${uid}, product=${product_id}, env=${environment}`);

  // Ignoramos eventos de sandbox en producción (opcional)
  // if (environment === 'SANDBOX') return res.status(200).send('Sandbox ignored');

  // ── Determinar nuevo estado premium ────────────────────────────────────────
  let isPremium;

  if (PREMIUM_EVENTS.has(type)) {
    isPremium = true;
  } else if (NON_PREMIUM_EVENTS.has(type)) {
    isPremium = false;
  } else {
    functions.logger.info(`Evento no manejado: ${type}`);
    return res.status(200).send(`Event "${type}" not handled`);
  }

  // ── Actualizar Firestore ───────────────────────────────────────────────────
  if (!uid) {
    functions.logger.error('app_user_id vacío en el evento');
    return res.status(400).send('Missing app_user_id');
  }

  try {
    // Protección para usuarios con premium concedido por código de invitación.
    // Solo se comprueba cuando el webhook va a revocar el acceso (isPremium=false),
    // ya que otorgar premium nunca causa daño.
    if (!isPremium) {
      const userDoc = await db.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data()?.premiumSource === 'codigo') {
        functions.logger.info(
          `🛡 Usuario ${uid} tiene premium por código de invitación. ` +
          `Evento ${type} ignorado para proteger su acceso.`
        );
        // Respondemos 200 para que RevenueCat no reintente el webhook.
        return res.status(200).send('Protected');
      }
    }

    await db.collection('users').doc(uid).update({
      isPremium,
      premiumUpdatedAt:      admin.firestore.FieldValue.serverTimestamp(),
      lastRevenuecatEvent:   type,
      lastRevenuecatProduct: product_id ?? null,
    });

    functions.logger.info(`✅ Usuario ${uid} actualizado: isPremium=${isPremium} (${type})`);
    return res.status(200).send('OK');
  } catch (error) {
    functions.logger.error(`Error actualizando usuario ${uid}:`, error);
    return res.status(500).send('Firestore update failed');
  }
});
