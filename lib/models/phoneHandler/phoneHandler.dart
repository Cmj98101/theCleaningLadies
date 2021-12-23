import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_cleaning_ladies/models/SMS/message.dart';
import 'package:the_cleaning_ladies/models/appointment_model/appointment.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:twilioFlutter/models/sms.dart';
import 'package:twilioFlutter/twilioFlutter.dart';

class PhoneHandler {
  String testSID = 'AC1ac1530f724c58596d7bb13e9d8b6f1a';
  String testAuth = 'c0017e86bd2259221fb3a479445c9019';

  String liveSID = 'AC96526016b76c4b23da1433373f5207e0';
  String liveAuth = '2537da78be327dd38acad822dfc97949';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String optionsMSG = '''
Please reply "1" to confirm and "2" to reschedule.''';

  Admin admin;
  TwilioFlutter _twilioFlutter;

  PhoneHandler.init({@required this.admin});

  TwilioFlutter setupTwilioFlutter() => _twilioFlutter = TwilioFlutter(
        accountSid: liveSID,
        authToken: liveAuth,
        twilioNumber: admin.twilioNumber,
      );

  Future<List<PhoneNumber>> searchAvailbleNumbers(Function(bool) isLoading,
      {String areaCode = '',
      int pageSize = 20,
      bool smsEnabled = true,
      bool voiceEnabled = true}) async {
    setupTwilioFlutter();
    return await _twilioFlutter.getAvailablePhoneNumbers(isLoading,
        areaCode: areaCode,
        pageSize: pageSize,
        smsEnabled: smsEnabled,
        voiceEnabled: voiceEnabled);
  }

  Future<List<PhoneNumber>> getActivePhoneNumbers(
    Function(bool) isLoading,
  ) async {
    setupTwilioFlutter();
    return await _twilioFlutter.getActivePhoneNumbers(
      isLoading,
    );
  }

  Future<void> provisionPhoneNumber(Function(bool) isLoading,
      {String phoneNumber, @required Function() onDone}) async {
    setupTwilioFlutter();
    return await _twilioFlutter.provisionPhoneNumber(
      isLoading,
      phoneNumber: phoneNumber,
      onDone: () => onDone(),
    );
  }

  void reply(String body, String to, Client client) async {
    setupTwilioFlutter();
    await _twilioFlutter
        .sendSMS(toNumber: to, messageBody: body)
        .whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': to,
        'from': admin.twilioNumber,
        'body': body,
        'adminUserId': admin.id,
        'createdAt': DateTime.now()
      });
      print('Message sent');
    });
  }

  void replyWithMedia(
      String body, String to, Client client, String mediaUrl) async {
    setupTwilioFlutter();
    await _twilioFlutter
        .sendMediaSMS(toNumber: to, messageBody: body, mediaUrl: mediaUrl)
        .whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': to,
        'from': admin.twilioNumber,
        'body': body,
        'mediaUrl': mediaUrl,
        'createdAt': DateTime.now()
      });
      print('Message sent');
    });
  }

  String createDynamicMessage(
      String message, Appointment appointment, Client client,
      {List<dynamic> values}) {
    int index = 1;
    Map<String, dynamic> fillInValues = {
      'First Name': client.firstName,
      'Last Name': client.lastName,
      'Service Cost': appointment.serviceCost.toString(),
      'Full Date & Time': appointment.getMsgReadyFullDateTime,
    };
    return message.replaceAllMapped(
        RegExp(r'(\{\d{1}\})', multiLine: true, caseSensitive: false), (m) {
      // Add all values not found in Map to a list and list those
      // values in a User Friendly way
      String value = fillInValues[values[index - 1]] ??
          '{${values[index - 1]} value is unknown}';
      index++;
      return value;
    });
  }

  void sendAutoReminder(
      Appointment appointment, Function(bool) requestResponse) async {
    setupTwilioFlutter();
    DocumentSnapshot clientSnap =
        await _db.doc(appointment.clientReference).get();
    Client client = Client.fromDocumentSnap(clientSnap);
    String msg;
    if (client.templateReminderMsg.isEmpty) {
      msg = createDynamicMessage(admin.templateReminderMsg, appointment, client,
          values: admin.templateFillInValues);
      print(createDynamicMessage(admin.templateReminderMsg, appointment, client,
          values: admin.templateFillInValues));
    } else {
      msg = createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues);
      print(createDynamicMessage(
          client.templateReminderMsg, appointment, client,
          values: client.templateFillInValues));
    }

    Future.delayed(Duration(seconds: 1), () async {
      await _twilioFlutter.flow.sendAutoReminderRequest(
          (res, statusCode, data) => requestResponse(res),
          toNumber: client.formatPhoneNumber,
          id: appointment.appointmentId,
          clientId: appointment.client.id,
          adminUserId: admin.id,
          firstName: client.firstName,
          message: """
$msg
          
$optionsMSG
          """,
          flowSID: 'FWa0015a82a19e38f4b8348943762f0ba4');
    }).whenComplete(() {
      // _db.collection('Users/${client.id}/SMS').add({
      //   'to': client.formatPhoneNumber,
      //   'from': twilioNumber,
      //   'body': """$msg""",
      //   'createdAt': DateTime.now()
      // });
    });
  }

  void sendBroadcastMessageWithMedia({String mediaUrl = ''}) async {
    List<Client> clients = await admin.getAllClients(activeOnly: true);
    clients.forEach((client) {
      String msg = """
The Cleaning Ladies & More - IMPORTANT MESSAGE:
Dear ${client.firstName},

I want to take a moment this holiday season to personally thank you for your support and cooperation. 
I am so thankful and it has been a complete honor to work with you. 
I am wishing you and your loved ones a prosperous holiday season full of love, happiness and success. 
Thank you for your support and I look forward to working with you for many years to come.

""";
      print(
          '(${client.firstName}, ${client?.lastName ?? ''} active: ${client.active}) sending...');
      // if (client.contactNumber == '+19092223241') {
      sendSMSForBroadcast(client, msg, mediaUrl: mediaUrl);
      // }
    });
  }

  void sendSMSForBroadcast(
    Client client,
    String messageBody, {
    String mediaUrl = '',
  }) {
    setupTwilioFlutter();

    Future.delayed(Duration(seconds: 2), () async {
      await _twilioFlutter.sendMediaSMS(
          toNumber: client.formatPhoneNumber,
          messageBody: """$messageBody""",
          mediaUrl: mediaUrl);
    }).whenComplete(() {
      _db.collection('Users/${client.id}/SMS').add({
        'to': client.formatPhoneNumber,
        'from': admin.twilioNumber,
        'mediaUrl': mediaUrl,
        'body': """$messageBody""",
        'createdAt': DateTime.now()
      });
    });
  }

  Future<List<SMS>> getSmSList() async {
    setupTwilioFlutter();
    return await _twilioFlutter.getSmsList();
  }

  Stream<List<Message>> getSMS(Client client) {
    return _db
        .collection('Users/${client.id}/SMS')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => Message.fromDocument(doc)).toList();
    });
  }

  Future<List<SMS>> getSpecificSmSList(String from, String to) async {
    setupTwilioFlutter();
    return await _twilioFlutter.getSpecificSmsList(from, to);
  }
}



/** As you all may know my mother has passed away and I will no longer be able to use her business name.
// So starting Feb. 18th, 2021
// We are in a transition period. 

// If you could pay cash that would be much appreciated! (It is easier to pay the ladies).

// If cash is not possible:

// If you are paying by Check can you please make the check out to "The Cleaning Ladies & More"

 If you are paying by Zelle (Please Text me) Could you please pay by Cash or Check until I am able to send you another email that you can use. 
 */