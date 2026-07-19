const { setGlobalOptions } = require("firebase-functions");
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

setGlobalOptions({ maxInstances: 10, region: "us-central1" });

// ─── خريطة الحالات: قيمة Firestore → رسالة الإشعار ────────────────────────
const STATUS_MESSAGES = {
  ordered: {
    titleAr: "📦 تم استلام طلبك!",
    bodyAr: "شكراً لطلبك! سنبدأ في معالجته قريباً.",
    titleEn: "📦 Order Received!",
    bodyEn: "Thank you for your order! We'll start processing it soon.",
  },
  pending: {
    titleAr: "⏳ طلبك قيد المراجعة",
    bodyAr: "يتم مراجعة طلبك الآن. سنُعلمك عند التأكيد.",
    titleEn: "⏳ Your Order is Under Review",
    bodyEn: "Your order is being reviewed. We'll notify you once confirmed.",
  },
  confirmed: {
    titleAr: "✅ تم تأكيد طلبك!",
    bodyAr: "رائع! طلبك تم تأكيده وجارٍ تجهيزه.",
    titleEn: "✅ Order Confirmed!",
    bodyEn: "Great! Your order has been confirmed and is being prepared.",
  },
  processing: {
    titleAr: "🔧 طلبك قيد التجهيز",
    bodyAr: "فريقنا يجهز طلبك الآن بعناية.",
    titleEn: "🔧 Your Order is Being Prepared",
    bodyEn: "Our team is carefully preparing your order now.",
  },
  shipped: {
    titleAr: "🚚 طلبك في الطريق إليك!",
    bodyAr: "تم شحن طلبك وهو في طريقه إليك.",
    titleEn: "🚚 Your Order is On Its Way!",
    bodyEn: "Your order has been shipped and is on its way to you.",
  },
  delivered: {
    titleAr: "🎉 تم توصيل طلبك!",
    bodyAr: "نأمل أن تستمتع بمشترياتك! لا تنسَ تقييم تجربتك.",
    titleEn: "🎉 Your Order Has Been Delivered!",
    bodyEn: "We hope you enjoy your purchase! Don't forget to rate your experience.",
  },
  cancelled: {
    titleAr: "❌ تم إلغاء طلبك",
    bodyAr: "للأسف تم إلغاء طلبك. تواصل معنا لأي استفسار.",
    titleEn: "❌ Your Order Has Been Cancelled",
    bodyEn: "Unfortunately, your order has been cancelled. Contact us for any inquiries.",
  },
};

// ─── Cloud Function: onOrderStatusChanged ──────────────────────────────────
exports.onOrderStatusChanged = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const orderId = event.params.orderId;

    // 1. تحقق إن الـ status اتغير فعلاً
    if (!before || !after) {
      logger.warn("[FCM] Missing before/after data", { orderId });
      return null;
    }

    const oldStatus = (before.status || "").toLowerCase().trim();
    const newStatus = (after.status || "").toLowerCase().trim();

    if (oldStatus === newStatus) {
      logger.info("[FCM] Status unchanged, skipping", { orderId, status: newStatus });
      return null;
    }

    logger.info("[FCM] Status changed", { orderId, from: oldStatus, to: newStatus });

    // 2. جيب الـ userId من الـ order
    const userId = after.userId;
    if (!userId) {
      logger.warn("[FCM] No userId in order", { orderId });
      return null;
    }

    // 3. جيب الـ FCM token واللغة من Firestore
    let fcmToken;
    let userLang = 'ar';
    try {
      const userDoc = await getFirestore().collection("users").doc(userId).get();
      if (!userDoc.exists) {
        logger.warn("[FCM] User doc not found", { userId });
        return null;
      }
      const userData = userDoc.data();
      fcmToken = userData?.fcmToken;
      userLang = userData?.appLanguage || 'ar';
    } catch (err) {
      logger.error("[FCM] Error fetching user doc", { userId, err });
      return null;
    }

    if (!fcmToken) {
      logger.warn("[FCM] No FCM token for user", { userId });
      return null;
    }

    // 4. جيب نص الإشعار حسب الحالة الجديدة
    const msgTemplate = STATUS_MESSAGES[newStatus];
    if (!msgTemplate) {
      logger.warn("[FCM] Unknown status, no message template", { newStatus });
      return null;
    }

    // 5. ابعت الـ FCM notification باللغة المناسبة
    const shortOrderId = orderId.substring(0, 8).toUpperCase();
    const title = userLang === 'en' && msgTemplate.titleEn ? msgTemplate.titleEn : msgTemplate.titleAr;
    const body = userLang === 'en' && msgTemplate.bodyEn ? msgTemplate.bodyEn : msgTemplate.bodyAr;
    const message = {
      token: fcmToken,
      notification: {
        title,
        body: `${userLang === 'en' ? 'Order' : 'طلب'} #${shortOrderId} — ${body}`,
      },
      data: {
        type: "order",
        id: orderId,
        status: newStatus,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await getMessaging().send(message);
      logger.info("[FCM] Notification sent successfully", {
        orderId,
        userId,
        newStatus,
        messageId: response,
      });
    } catch (err) {
      // لو الـ token انتهى أو مش صالح، احذفه من Firestore
      if (
        err.code === "messaging/invalid-registration-token" ||
        err.code === "messaging/registration-token-not-registered"
      ) {
        logger.warn("[FCM] Invalid token, removing from Firestore", { userId });
        await getFirestore()
          .collection("users")
          .doc(userId)
          .update({ fcmToken: FieldValue.delete() });
      } else {
        logger.error("[FCM] Error sending notification", { orderId, err: err.message });
      }
    }

    return null;
  }
);

/**
 * sendNotification — ترسل FCM لـ:
 *   - target === 'all'        → topic 'all'
 *   - target = userId string  → تجيب tokens من Firestore وترسل multicast
 *   - target = fcm_token      → token مباشر (يبدأ بـ حروف طويلة)
 *   - target = Array          → multicast لعدة tokens مباشرة
 *
 * الـ Function نفسها بتجيب tokens المستخدم عبر Admin SDK (بدون Firestore rules)
 */
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.onNotificationCreated = onDocumentCreated("notifications/{notifId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.warn("[FCM] No data associated with the event");
    return;
  }

  const data = snapshot.data();
  const { title, body, audience, targetUserId, data: extraData, status } = data;

  if (status === 'sent') return;

  if (!title || !body) {
    logger.warn("[FCM] Title and body are required", { notifId: event.params.notifId });
    return;
  }

  const db = getFirestore();
  const messaging = getMessaging();
  const notification = { title, body };
  const androidConfig = {
    notification: { sound: 'default', channelId: 'order_channel' },
  };
  const apnsConfig = {
    payload: { aps: { sound: 'default' } },
  };
  const msgData = extraData || {};

  try {
    let successCount = 0;

    if (audience === 'all') {
      const usersSnap = await db.collection('users').get();
      const allTokens = [];
      usersSnap.forEach(doc => {
        const u = doc.data();
        if (u.fcmToken) allTokens.push(u.fcmToken);
        if (Array.isArray(u.fcmTokens)) allTokens.push(...u.fcmTokens);
      });
      const uniqueTokens = [...new Set(allTokens.filter(Boolean))];
      if (uniqueTokens.length > 0) {
        if (uniqueTokens.length === 1) {
          await messaging.send({ token: uniqueTokens[0], notification, android: androidConfig, apns: apnsConfig, data: msgData });
        } else {
          const response = await messaging.sendEachForMulticast({ tokens: uniqueTokens, notification, android: androidConfig, apns: apnsConfig, data: msgData });
          successCount = response.successCount;
        }
      }
    } else if (targetUserId) {
      const userDoc = await db.collection('users').doc(targetUserId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        const tokens = [];
        if (userData.fcmToken) tokens.push(userData.fcmToken);
        if (Array.isArray(userData.fcmTokens)) tokens.push(...userData.fcmTokens);
        const uniqueTokens = [...new Set(tokens.filter(Boolean))];

        if (uniqueTokens.length > 0) {
          const response = await messaging.sendEachForMulticast({
            tokens: uniqueTokens,
            notification,
            android: androidConfig,
            apns: apnsConfig,
            data: msgData,
          });
          successCount = response.successCount;
        }
      }
    }

    await snapshot.ref.update({
      status: 'sent',
      sentAt: FieldValue.serverTimestamp(),
      successCount,
    });
    logger.info("[FCM] Notification sent", { notifId: event.params.notifId, successCount });
  } catch (error) {
    logger.error("[FCM] Error sending notification", { notifId: event.params.notifId, error: error.message });
    await snapshot.ref.update({ status: 'failed', error: error.message });
  }
});

// ─── ميزات Blaze الإضافية ─────────────────────────────────────────────
const { onObjectFinalized } = require("firebase-functions/v2/storage");
const authV1 = require("firebase-functions/v1/auth");
const { Storage } = require("@google-cloud/storage");
const sharp = require("sharp");
const path = require("path");
const os = require("os");
const fs = require("fs");

const gcs = new Storage();

// 1. الحذف التلقائي للمستخدم وبياناته
exports.cleanupUserAccount = authV1.user().onDelete(async (user) => {
  const uid = user.uid;
  logger.info(`[Auth] User deleted: ${uid}. Cleaning up data...`);

  const db = getFirestore();
  const batch = db.batch();

  try {
    // 1. حذف مستند المستخدم
    const userRef = db.collection("users").doc(uid);
    batch.delete(userRef);

    // 2. حذف سلة المشتريات الخاصة به
    const cartRef = db.collection("carts").doc(uid);
    batch.delete(cartRef);

    await batch.commit();
    logger.info(`[Auth] Successfully cleaned up data for user: ${uid}`);
  } catch (error) {
    logger.error(`[Auth] Error cleaning up data for user: ${uid}`, error);
  }
});

// 2. التصغير التلقائي للصور المرفوعة وتحويلها لـ WebP
exports.optimizeStorageImage = onObjectFinalized(
  {
    region: "us-east1", // تم إضافة الـ Region لحل مشكلة الديبلوى
    cpu: 2,
    memory: "1GiB",
  },
  async (event) => {
    const fileBucket = event.data.bucket;
    const filePath = event.data.name;
    const contentType = event.data.contentType;

    // التأكد إن الملف ده صورة ومش متصغر قبل كده
    if (!contentType || !contentType.startsWith("image/")) {
      return logger.info(`[ImageResize] Not an image: ${filePath}`);
    }

    // منع حدوث Infinite Loop بتجاهل الصور اللي تم معالجتها
    if (event.data.metadata && event.data.metadata.isOptimized) {
      return logger.info(`[ImageResize] Already optimized: ${filePath}`);
    }

    const fileName = path.basename(filePath);
    const bucket = gcs.bucket(fileBucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);

    // تغيير الامتداد لـ webp
    const parsedPath = path.parse(fileName);
    const optimizedFileName = `${parsedPath.name}.webp`;
    const tempOptimizedPath = path.join(os.tmpdir(), optimizedFileName);
    const optimizedFilePath = path.join(path.dirname(filePath), optimizedFileName);

    logger.info(`[ImageResize] Optimizing image: ${filePath}`);

    try {
      // تنزيل الصورة للسيرفر
      await bucket.file(filePath).download({ destination: tempFilePath });

      // تصغير وضغط الصورة باستخدام sharp
      await sharp(tempFilePath)
        .resize({ width: 1080, withoutEnlargement: true }) // أقصى عرض 1080
        .webp({ quality: 80 }) // تحويل لـ webp بجودة 80%
        .toFile(tempOptimizedPath);

      // رفع الصورة المصغرة مكان الأصلية
      await bucket.upload(tempOptimizedPath, {
        destination: optimizedFilePath,
        metadata: {
          contentType: "image/webp",
          metadata: { isOptimized: "true" } // علامة عشان الدالة ماتشتغلش عليها تاني
        }
      });

      // حذف الصورة الأصلية لو كانت بصيغة تانية (زي png أو jpg) عشان توفير المساحة
      if (filePath !== optimizedFilePath) {
        await bucket.file(filePath).delete();
        logger.info(`[ImageResize] Deleted original file: ${filePath}`);
      }

      logger.info(`[ImageResize] Successfully optimized: ${optimizedFilePath}`);

      // تنظيف الملفات المؤقتة من السيرفر
      fs.unlinkSync(tempFilePath);
      fs.unlinkSync(tempOptimizedPath);
    } catch (error) {
      logger.error(`[ImageResize] Error optimizing image: ${filePath}`, error);
      // تنظيف الملفات المؤقتة في حالة الخطأ
      if (fs.existsSync(tempFilePath)) fs.unlinkSync(tempFilePath);
      if (fs.existsSync(tempOptimizedPath)) fs.unlinkSync(tempOptimizedPath);
    }
  }
);

// DEPLOY_FIX_20260708200833
