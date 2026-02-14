import * as admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

// Initialize Firebase Admin SDK
let firebaseInitialized = false;

function initializeFirebase() {
    if (firebaseInitialized) return true;

    try {
        // Option 1: Load from environment variable (for Railway/production)
        const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
        if (serviceAccountJson) {
            const serviceAccount = JSON.parse(serviceAccountJson);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
            });
            firebaseInitialized = true;
            console.log('[Firebase] Initialized from environment variable');
            return true;
        }

        // Option 2: Load from file (for local development)
        const serviceAccountPath = path.join(__dirname, '..', '..', 'firebase-service-account.json');
        if (fs.existsSync(serviceAccountPath)) {
            const serviceAccount = require(serviceAccountPath);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
            });
            firebaseInitialized = true;
            console.log('[Firebase] Initialized from service account file');
            return true;
        }

        console.log('[Firebase] No credentials found. Push notifications disabled.');
        return false;
    } catch (error) {
        console.error('[Firebase] Failed to initialize:', error);
        return false;
    }
}

// Initialize on module load
initializeFirebase();

export interface PushNotificationPayload {
    title: string;
    body: string;
    data?: Record<string, string>;
}

/**
 * Send a push notification to a specific user
 */
export async function sendPushNotification(
    fcmToken: string,
    payload: PushNotificationPayload
): Promise<boolean> {
    if (!firebaseInitialized) {
        console.log('[Push] Firebase not initialized, skipping notification');
        return false;
    }

    if (!fcmToken) {
        console.log('[Push] No FCM token provided, skipping notification');
        return false;
    }

    try {
        const message: admin.messaging.Message = {
            token: fcmToken,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data || {},
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'high_importance_channel',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        const response = await admin.messaging().send(message);
        console.log('[Push] Notification sent successfully:', response);
        return true;
    } catch (error: any) {
        console.error('[Push] Failed to send notification:', error.message);
        // If token is invalid, we might want to clear it from the database
        if (error.code === 'messaging/registration-token-not-registered') {
            console.log('[Push] Token is invalid/unregistered');
        }
        return false;
    }
}

/**
 * Send notification for a new match
 */
export async function sendMatchNotification(
    fcmToken: string,
    matchedProductTitle: string,
    matchId: number
): Promise<boolean> {
    return sendPushNotification(fcmToken, {
        title: "It's a Match! 🎉",
        body: `Someone wants to trade for "${matchedProductTitle}"`,
        data: {
            type: 'match',
            matchId: matchId.toString(),
        },
    });
}

/**
 * Send notification for a new message
 */
export async function sendMessageNotification(
    fcmToken: string,
    senderUsername: string,
    messagePreview: string,
    matchId: number
): Promise<boolean> {
    const truncatedMessage = messagePreview.length > 50
        ? messagePreview.substring(0, 47) + '...'
        : messagePreview;

    return sendPushNotification(fcmToken, {
        title: `New message from ${senderUsername}`,
        body: truncatedMessage,
        data: {
            type: 'message',
            matchId: matchId.toString(),
        },
    });
}

/**
 * Send notification for trade completion
 */
export async function sendTradeCompletedNotification(
    fcmToken: string,
    productTitle: string,
    tradeRequestId: number
): Promise<boolean> {
    return sendPushNotification(fcmToken, {
        title: 'Trade Completed! ✅',
        body: `Your trade for "${productTitle}" has been completed`,
        data: {
            type: 'trade_completed',
            tradeRequestId: tradeRequestId.toString(),
        },
    });
}

/**
 * Send notification for trade confirmation needed
 */
export async function sendTradeConfirmationNeededNotification(
    fcmToken: string,
    productTitle: string,
    tradeRequestId: number
): Promise<boolean> {
    return sendPushNotification(fcmToken, {
        title: 'Please Confirm Trade',
        body: `The other party marked the trade for "${productTitle}" as complete. Please confirm.`,
        data: {
            type: 'trade_pending',
            tradeRequestId: tradeRequestId.toString(),
        },
    });
}
