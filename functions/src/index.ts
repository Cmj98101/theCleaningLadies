import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';


admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

const db = admin.firestore();
const fcm = admin.messaging();

// .where('contactNumber', '==', request.from)


// exports.scheduledFunction = functions.pubsub
//   .schedule("every 60 minutes")
//   .onRun((context) => {
//     console.log("This will be run every 60 minutes!");
//     return null;
//   });

exports.onRequest = functions.https.onRequest(async (request, res) => {
  await db.doc(`Users/${request.body.adminUserId}/Appointments/${request.body.appointmentId}`).update({ 'isReminderSent': true, 'flowSID': `${request.body.flowSID}`, 'executionSID': `${request.body.executionSID}` });
  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'from': request.body.from, 'adminUserId': request.body.adminUserId,
    'to': request.body.to, 'body': request.body.body, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });

  res.status(200).send(`Confirmed ${request.body.appointmentId}`);

});
exports.onIncomingMessage = functions.https.onRequest(async (request, res) => {

  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'fromName': request.body.firstName, 'clientId': `${request.body.clientId}`, 'adminUserId': request.body.adminUserId, 'from': request.body.inboundFrom,
    'to': request.body.inboundTo, 'body': request.body.inboundBody, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });



  res.status(200).send(`onIcoming ${request.body.inboundFrom} ${request.body.inboundBody}`);

});
exports.onMessageTrigger = functions.https.onRequest(async (request, res) => {

  await db.collection('Users').where('contactNumber', '==', `${request.body.from}`).get().then(function (snap) {

    snap.docs.map(async (doc) => {
      const data = doc.data();
      const adminRef = db.collection('Users')
        .doc(`${data.adminUserId}`);
      const adminSnap = await
        adminRef
          .get();
      doc.ref.collection('SMS').doc().set({
        'fromName': data.firstName, 'clientId': data.id, 'adminUserId': adminSnap.id, 'from': request.body.from,
        'to': request.body.to, 'body': request.body.body, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
      }).catch((err) => { console.log("error creating SMS in DB ", err) });
      //   try {
      //         await db.runTransaction(async function (transactionSnap) {
      //   const clientFreshSnap = await transactionSnap.get(doc.ref);
      //   const clientNewNotificationCount = clientFreshSnap.get('notificationCount') + 1;
      //   transactionSnap.update(doc.ref, { notificationCount: clientNewNotificationCount });

      // });
      // await db.runTransaction(async function (transactionSnap) {

      //   const adminFreshSnap = await transactionSnap.get(adminRef);
      //   const adminNewNotificationCount = adminFreshSnap.get('notificationCount') + 1;
      //   transactionSnap.update(adminRef, { notificationCount: adminNewNotificationCount });

      // });
      //     console.log(`Update notification counter... Transaction success!`);
      //   } catch (e) {
      //     console.log('Update notifaction counter... Transaction failure:', e);
      //   }

    });
  });

  res.status(200).send(`onIcoming ${request.body.from} ${request.body.body}`);

});


exports.onNoMatch = functions.https.onRequest(async (request, res) => {

  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'from': request.body.from, 'adminUserId': request.body.adminUserId,
    'to': request.body.to, 'body': `${request.body.onNoMatchReply}`, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });
  res.status(200).send(`No Matches ${request.body.body}`);
});




exports.onReschedule = functions.https.onRequest(async (request, res) => {
  await db
    .doc(`Users/${request.body.adminUserId}/Appointments/${request.body.appointmentId}`)
    .update({ 'isConfirmed': false, 'isRescheduling': true });
  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'from': request.body.from, 'adminUserId': request.body.adminUserId,
    'to': request.body.to, 'body': `${request.body.onRescheduleReply}`, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });
  res.status(200).send(`Canceled & Rescheduled ${request.body.appointmentId}`);

});
exports.onConfirm = functions.https.onRequest(async (request, res) => {

  await db.doc(`Users/${request.body.clientId}/Cleaning History/${request.body.appointmentId}`).update({ 'isConfirmed': true });
  await db.doc(`Users/${request.body.adminUserId}/Appointments/${request.body.appointmentId}`).update({ 'isConfirmed': true });
  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'from': request.body.from, 'adminUserId': request.body.adminUserId,
    'to': request.body.to, 'body': `${request.body.onConfirmReply}`, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });


  res.status(200).send(`Confirmed ${request.body.appointmentId}`);

});
exports.onDone = functions.https.onRequest(async (request, res) => {
  await db
    .doc(`Users/${request.body.adminUserId}/Appointments/${request.body.appointmentId}`)
    .update({ 'isReminderSent': false });
  res.status(200).send(`Canceled ${request.body.appointmentId}`);
});


exports.onNoReply = functions.https.onRequest(async (request, res) => {
  await db
    .doc(`Users/${request.body.adminUserId}/Appointments/${request.body.appointmentId}`)
    .update({ 'noReply': true, 'isRescheduling': true });
  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({
    'from': request.body.from, 'adminUserId': request.body.adminUserId,
    'to': request.body.to, 'body': `${request.body.onNoReply}`, 'createdAt': admin.firestore.FieldValue.serverTimestamp()
  }).catch((err) => { console.log("error creating SMS in DB ", err) });
  res.status(200).send(`Canceled ${request.body.appointmentId}`);
});


export const sendToDeviceOnSMS = functions.firestore
  .document('/Users/{uid}/SMS/{smsId}')
  .onCreate(async snapshot => {


    const sms = snapshot.data();


    const adminRef = db
      .collection('Users')
      .doc(`${sms.adminUserId}`);
    const adminSnap = await adminRef
      .get();


    const apiPN = adminSnap.get('apiPN');
    if (sms.from !== apiPN) {
      const querySnapshot = await db
        .collection('Users')
        .doc(`${sms.adminUserId}`)
        .collection('Tokens')
        .get();
      const clientRef = await db
        .collection('Users')
        .doc(`${sms.clientId}`);

      const tokens = querySnapshot.docs.map(snap => snap.id);
      try {

        await db.runTransaction(async function (transactionSnap) {
          const clientFreshSnap = await transactionSnap.get(clientRef);
          const clientNewNotificationCount = clientFreshSnap.get('notificationCount') + 1;
          transactionSnap.update(clientRef, { notificationCount: clientNewNotificationCount });

        });
        await db.runTransaction(async function (snap) {
          const doc = await snap.get(adminRef);

          const newNotificationCount = doc.get('notificationCount') + 1;
          snap.update(adminRef, { notificationCount: newNotificationCount });
          if (sms.body === '1') {
            const payload: admin.messaging.MessagingPayload = {
              data: { clientId: `${sms.clientId}` },
              notification: {
                title: `Incoming Message from ${sms.fromName}!`,
                body: `Apointment Confirmed!`,
                icon: 'your-icon-url',
                badge: `${newNotificationCount}`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
              }



            };
            return fcm.sendToDevice(tokens, payload);

          } else if (sms.body === '2') {
            const payload: admin.messaging.MessagingPayload = {
              data: { clientId: `${sms.clientId}`, },
              notification: {
                title: `Incoming Message from ${sms.fromName}!`,
                body: `Reschedule Requested!`,
                icon: 'your-icon-url',
                badge: `${newNotificationCount}`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
              },
              

            };
            return fcm.sendToDevice(tokens, payload);

          } else {
            const payload: admin.messaging.MessagingPayload = {
              data: { clientId: `${sms.clientId}` },
              notification: {
                title: `Incoming Message from ${sms.fromName}!`,
                body: `${sms.body}`,
                icon: 'your-icon-url',
                badge: `${newNotificationCount}`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
              },
            };
            return fcm.sendToDevice(tokens, payload);
          }

        });

        console.log('On Notification... Update notification counter... Transaction success!');
      } catch (e) {
        console.log('On Notification... Update notifaction counter... Transaction failure:', e);
      }


    }
    return;

  });
