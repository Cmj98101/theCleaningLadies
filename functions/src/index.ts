import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';


admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

const db = admin.firestore();
// .where('contactNumber', '==', request.from)


// exports.scheduledFunction = functions.pubsub
//   .schedule("every 60 minutes")
//   .onRun((context) => {
//     console.log("This will be run every 60 minutes!");
//     return null;
//   });

exports.onRequest = functions.https.onRequest(async (request, res) => {
  await db.doc(`Appointments/${request.body.appointmentId}`).update({ 'isReminderSent': true });
  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.from,
      'to' : request.body.to, 'body': request.body.body, 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});
    
  res.status(200).send(`Confirmed ${request.body.appointmentId}`);

});
exports.onIncomingMessage = functions.https.onRequest(async (request, res) => {

  await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.inboundFrom,
      'to' : request.body.inboundTo, 'body': request.body.inboundBody, 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});
    
  
    
  res.status(200).send(`onIcoming ${request.body.inboundFrom} ${request.body.inboundBody}`);

});
exports.onMessageTrigger = functions.https.onRequest(async (request, res) => {

  await db.collection('Users').where('contactNumber', '==', `${request.body.from}`).get().then(function(snap){
    snap.docs.map(function(doc){
      doc.ref.collection('SMS').doc().set({'from': request.body.from,
      'to' : request.body.to, 'body': request.body.body, 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});
    });
  });
    
  res.status(200).send(`onIcoming ${request.body.from} ${request.body.body}`);

});

exports.onConfirm = functions.https.onRequest(async (request, res) => {
  
      await db.doc(`Users/${request.body.clientId}/Cleaning History/${request.body.appointmentId}`).update({'isConfirmed': true});
      await db.doc(`Appointments/${request.body.appointmentId}`).update({'isConfirmed': true});
      await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.from,
      'to' : request.body.to, 'body': 'Thank you!', 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});

      
        res.status(200).send(`Confirmed ${request.body.appointmentId}`);
      
});
exports.onNoMatch = functions.https.onRequest(async (request, res) => {

    await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.from,
        'to' : request.body.to, 'body': 'We\'re sorry, we couldn\'t understand your response.', 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});
  res.status(200).send(`No Matches ${request.body.body}`);
});
exports.onReschedule = functions.https.onRequest(async (request, res) => {
      await db
        .doc(`Appointments/${request.body.appointmentId}`)
        .update({ 'isConfirmed': false, 'isRescheduling': true});
        await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.from,
        'to' : request.body.to, 'body': 'We understand that plans change. Thanks for letting us know! Someone will be reaching out to you to reschedule!', 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});  
        res.status(200).send(`Canceled & Rescheduled ${request.body.appointmentId}`);

      });

exports.onDone = functions.https.onRequest(async (request, res) => {
  await db
    .doc(`Appointments/${request.body.appointmentId}`)
    .update({ 'isReminderSent': false});
  res.status(200).send(`Canceled ${request.body.appointmentId}`);
});


exports.onNoReply = functions.https.onRequest(async (request, res) => {
  await db
    .doc(`Appointments/${request.body.appointmentId}`)
    .update({ 'noReply': true,});
    await db.collection(`Users/${request.body.clientId}/SMS`).doc().set({'from': request.body.from,
        'to' : request.body.to, 'body': 'Unfortunately we did not recieve a reply from you. Someone will be contacting you soon.', 'createdAt': admin.firestore.FieldValue.serverTimestamp()}).catch((err)=>{console.log("error creating SMS in DB ", err)});
  res.status(200).send(`Canceled ${request.body.appointmentId}`);
});
