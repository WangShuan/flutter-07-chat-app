const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnNewMessage = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();

    const payload = {
      notification: {
        title: messageData.username + '發送了一條訊息',
        body: messageData.text,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      },
    };

    return admin.messaging().sendToTopic("chatapp", payload);
  });
