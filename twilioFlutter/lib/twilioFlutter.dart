// ignore: library_names
library twilioFlutter;

import 'package:meta/meta.dart';
import 'package:twilioFlutter/models/sms.dart';
import 'dart:convert';
import 'package:twilioFlutter/services/network.dart';

class TwilioFlutter {
  String _twilioNumber;
  String _toNumber, _messageBody;
  NetworkHelper _networkHelper = NetworkHelper();
  Map<String, String> _auth = Map<String, String>();
  String _url;
  final _baseUri = "https://api.twilio.com";
  String _version = '2010-04-01';
  List<SMS> _smsList = [];
  SMS _sms = SMS();

  TwilioFlutter(
      {@required String accountSid,
      @required String authToken,
      @required String twilioNumber}) {
    this._auth['accountSid'] = accountSid;
    this._auth['authToken'] = authToken;
    this._auth['twilioNumber'] = this._twilioNumber = twilioNumber;
    this._auth['baseUri'] = _baseUri;
    this._auth['cred'] = '$accountSid:$authToken';
    this._url = '$_baseUri/$_version/Accounts/$accountSid/Messages.json';
  }
  Future sendAutoReminder(Function(bool) requestResponse,
      {@required String toNumber,
      @required String id,
      @required String clientId,
      @required String message}) async {
    this._toNumber = toNumber;
    String cred = this._auth['cred'];

    var bytes = utf8.encode(cred);
    var base64Str = base64.encode(bytes);

    var headers = {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    _networkHelper.postAutoReminder(
        'https://studio.twilio.com/v1/Flows/FW7a24ac9621259b61ba55f73c353c91dd/Executions',
        headers,
        {
          'Parameters': jsonEncode(
            <String, String>{
              'message': '$message',
              'appointmentId': '$id',
              'clientId': '$clientId',
              'from': this._twilioNumber,
              'to': this._toNumber,
              'body': message,
              'waitTimer': '7200'
            },
          ),
          'From': this._twilioNumber,
          'To': this._toNumber,
        },
        (response) => requestResponse(response));
  }

  Future sendSMS(
      {@required String toNumber, @required String messageBody}) async {
    String cred = this._auth['cred'];
    this._toNumber = toNumber;
    this._messageBody = messageBody;
    var bytes = utf8.encode(cred);
    var base64Str = base64.encode(bytes);

    var headers = {
      'Authorization': 'Basic $base64Str',
      'Accept': 'application/json'
    };
    var body = {
      'From': this._twilioNumber,
      'To': this._toNumber,
      'Body': this._messageBody
    };

    _networkHelper.postMessageRequest(_url, headers, body);
  }

  changeTwilioNumber(String twilioNumber) {
    this._twilioNumber = twilioNumber;
  }

  sendWhatsApp(
      {@required String toNumber, @required String messageBody}) async {
    String cred = this._auth['cred'];
    this._toNumber = toNumber;
    this._messageBody = messageBody;
    var bytes = utf8.encode(cred);
    var base64Str = base64.encode(bytes);
    var headers = {
      'Authorization': 'Basic $base64Str',
      'Accept': 'application/json'
    };
    var body = {
      'From': 'whatsapp:' + this._twilioNumber,
      'To': 'whatsapp:' + this._toNumber,
      'Body': this._messageBody
    };

    _networkHelper.postMessageRequest(_url, headers, body);
  }

// 'https://api.twilio.com/2010-04-01/Accounts/AC96526016b76c4b23da1433373f5207e0/Messages.json?To=%2B1909222341&From=%2B16503752428'
  Future<List<SMS>> getSmsList() async {
    var getUri = 'https://' +
        this._auth['accountSid'] +
        ':' +
        this._auth['authToken'] +
        '@api.twilio.com/' +
        _version +
        '/Accounts/' +
        this._auth['accountSid'] +
        '/Messages.json';
    print(getUri);
    return this._smsList = await _sms.getSMSList(getUri);
  }

  Future<List<SMS>> getSpecificSmsList(String from, String to) async {
    var getUri = 'https://' +
        this._auth['accountSid'] +
        ':' +
        this._auth['authToken'] +
        '@api.twilio.com/' +
        _version +
        '/Accounts/' +
        this._auth['accountSid'] +
        '/Messages.json' +
        '?To=$to&From=$from';
    print(getUri);
    return this._smsList = await _sms.getSMSList(getUri);
  }

  getSMS(var messageSid) {
    bool found = false;
    for (var sms in this._smsList) {
      if (sms.messageSid == messageSid) {
        print('Message body : ' + sms.body);
        print('To : ' + sms.to);
        print('Sms status : ' + sms.status);
        print('Message URL :' + 'https://api.twilio.com' + sms.messageURL);
        found = true;
      }
    }
    if (!found) print('Not Found');
  }
}
