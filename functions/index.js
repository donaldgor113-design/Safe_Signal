const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");
const { defineString } = require("firebase-functions/params");

initializeApp();

const twilioAccountSid = defineString("TWILIO_ACCOUNT_SID");
const twilioAuthToken = defineString("TWILIO_AUTH_TOKEN");
const twilioPhoneNumber = defineString("TWILIO_PHONE_NUMBER");
const telegramBotToken = defineString("TELEGRAM_BOT_TOKEN");

exports.sendSosAlert = onDocumentCreated("alerts/{alertId}", async (event) => {
  const db = getFirestore();
  const alertData = event.data.data();
  const alertId = event.params.alertId;

  if (!alertData) return;

  const { userId, scenarioId, location, locationAddress, videoUrl } = alertData;

  let userName = "Користувач SafeSignal";
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (userDoc.exists) {
      userName = userDoc.data().displayName || userName;
    }
  } catch (_) {}

  let medicalInfo = "";
  try {
    const profileDoc = await db.collection("medical_profiles").doc(userId).get();
    if (profileDoc.exists) {
      const profile = profileDoc.data();
      if (profile.diagnoses && profile.diagnoses.length > 0) {
        medicalInfo = profile.diagnoses[0];
      }
    }
  } catch (_) {}

  let contactIds = [];
  try {
    const scenarioDoc = await db.collection("scenarios").doc(userId)
      .collection("items").doc(scenarioId).get();
    if (scenarioDoc.exists) {
      contactIds = scenarioDoc.data().contactIds || [];
    }
  } catch (_) {}

  if (contactIds.length === 0) {
    const contactsSnap = await db.collection("contacts").doc(userId)
      .collection("items").get();
    contactIds = contactsSnap.docs.map((d) => d.id);
  }

  const lat = location ? location.latitude : 0;
  const lng = location ? location.longitude : 0;
  const mapsUrl = `https://maps.google.com/?q=${lat},${lng}`;
  const timestamp = new Date().toLocaleString("uk-UA", { timeZone: "Europe/Kyiv" });
  const address = locationAddress || `${lat}, ${lng}`;

  const deliveryStatus = {};

  for (const contactId of contactIds) {
    try {
      const contactDoc = await db.collection("contacts").doc(userId)
        .collection("items").doc(contactId).get();

      if (!contactDoc.exists) continue;
      const contact = contactDoc.data();
      const channels = contact.notifyChannels || [];

      if (channels.includes("sms") && contact.phone) {
        try {
          const twilio = require("twilio")(
            twilioAccountSid.value(),
            twilioAuthToken.value()
          );
          const smsBody = [
            `🆘 SOS від ${userName}!`,
            `📍 ${address}`,
            `🗺 ${mapsUrl}`,
            `🕐 ${timestamp}`,
            medicalInfo ? `🏥 ${medicalInfo}` : "",
            videoUrl ? `📹 Відео: ${videoUrl}` : "",
          ].filter(Boolean).join("\n");

          await twilio.messages.create({
            body: smsBody,
            from: twilioPhoneNumber.value(),
            to: contact.phone,
          });
          deliveryStatus[`sms_${contactId}`] = "sent";
        } catch (e) {
          deliveryStatus[`sms_${contactId}`] = "failed";
        }
      }

      if (channels.includes("telegram") && contact.telegramChatId) {
        try {
          const fetch = require("node-fetch");
          const telegramText = [
            `<b>🆘 SOS від ${userName}!</b>`,
            ``,
            `📍 <b>Локація:</b> ${address}`,
            `🗺 <a href="${mapsUrl}">Карта</a>`,
            `🕐 <b>Час:</b> ${timestamp}`,
            medicalInfo ? `🏥 <b>Діагноз:</b> ${medicalInfo}` : "",
            videoUrl ? `📹 <a href="${videoUrl}">Відео</a>` : "",
          ].filter(Boolean).join("\n");

          const url = `https://api.telegram.org/bot${telegramBotToken.value()}/sendMessage`;
          const res = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              chat_id: contact.telegramChatId,
              text: telegramText,
              parse_mode: "HTML",
            }),
          });

          if (res.ok) {
            deliveryStatus[`telegram_${contactId}`] = "sent";
          } else {
            deliveryStatus[`telegram_${contactId}`] = "failed";
          }
        } catch (e) {
          deliveryStatus[`telegram_${contactId}`] = "failed";
        }
      }
    } catch (_) {}
  }

  const sentChannels = [...new Set(
    Object.entries(deliveryStatus)
      .filter(([, v]) => v === "sent")
      .map(([k]) => k.split("_")[0])
  )];

  await db.collection("alerts").doc(alertId).update({
    deliveryStatus,
    sentChannels,
  });
});

exports.generateSignedUrl = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { userId, filePath } = request.data;

  if (request.auth.uid !== userId) {
    throw new HttpsError("permission-denied", "Access denied");
  }

  const bucket = getStorage().bucket();
  const file = bucket.file(filePath);
  const [exists] = await file.exists();
  if (!exists) {
    throw new HttpsError("not-found", "File not found");
  }

  const [url] = await file.getSignedUrl({
    action: "read",
    expires: Date.now() + 48 * 60 * 60 * 1000,
  });

  return {
    url,
    expiresAt: new Date(Date.now() + 48 * 60 * 60 * 1000).toISOString(),
  };
});

exports.sendTestNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  const { contactId } = request.data;
  const userId = request.auth.uid;
  const db = getFirestore();

  let userName = "Користувач SafeSignal";
  try {
    const userDoc = await db.collection("users").doc(userId).get();
    if (userDoc.exists) {
      userName = userDoc.data().displayName || userName;
    }
  } catch (_) {}

  const contactDoc = await db.collection("contacts").doc(userId)
    .collection("items").doc(contactId).get();

  if (!contactDoc.exists) {
    throw new HttpsError("not-found", "Contact not found");
  }

  const contact = contactDoc.data();
  const channels = contact.notifyChannels || [];
  const results = {};

  const testMessage = `✅ Тестове повідомлення від ${userName} через SafeSignal. Якщо ви отримали це — канал працює.`;

  if (channels.includes("sms") && contact.phone) {
    try {
      const twilio = require("twilio")(
        twilioAccountSid.value(),
        twilioAuthToken.value()
      );
      await twilio.messages.create({
        body: testMessage,
        from: twilioPhoneNumber.value(),
        to: contact.phone,
      });
      results.sms = "sent";
    } catch (e) {
      results.sms = "failed";
    }
  }

  if (channels.includes("telegram") && contact.telegramChatId) {
    try {
      const fetch = require("node-fetch");
      const url = `https://api.telegram.org/bot${telegramBotToken.value()}/sendMessage`;
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: contact.telegramChatId,
          text: testMessage,
        }),
      });
      results.telegram = res.ok ? "sent" : "failed";
    } catch (e) {
      results.telegram = "failed";
    }
  }

  return results;
});
