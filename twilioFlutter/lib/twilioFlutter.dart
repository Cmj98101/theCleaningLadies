// ignore: library_names
library twilioFlutter;

import 'package:meta/meta.dart';
import 'package:twilioFlutter/models/flow/flow.dart';
import 'package:twilioFlutter/models/sms.dart';
import 'dart:convert';
import 'package:twilioFlutter/services/network.dart';

class TwilioFlutter {
  String _twilioNumber;
  String _toNumber, _messageBody;

  NetworkHelper _networkHelper = NetworkHelper();
  Flow flow;
  Map<String, String> _auth = Map<String, String>();
  String _url;
  String _provisionphoneNumberUrl;
  String _searchphoneNumberUrl;
  String _activeNumbersUrl;
  String _editActiveNumberUrl;
  final _baseUri = "https://api.twilio.com";
  String _version = '2010-04-01';
  List<SMS> _smsList = [];
  SMS _sms = SMS();
  var headers;
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
    this._provisionphoneNumberUrl =
        '$_baseUri/$_version/Accounts/$accountSid/IncomingPhoneNumbers.json';
    this._searchphoneNumberUrl =
        '$_baseUri/$_version/Accounts/$accountSid/AvailablePhoneNumbers/US/Local.json';
    this._activeNumbersUrl =
        '$_baseUri/$_version/Accounts/$accountSid/IncomingPhoneNumbers.json';
    this._editActiveNumberUrl =
        '$_baseUri/$_version/Accounts/$accountSid/IncomingPhoneNumbers';
    headers = setupHeaders();
    flow = Flow(headers: headers, sid: 'FWa0015a82a19e38f4b8348943762f0ba4');
    flow.twilioNumber = twilioNumber;
  }

  dynamic setupHeaders() {
    String cred = this._auth['cred'];

    var bytes = utf8.encode(cred);
    var base64Str = base64.encode(bytes);

    return {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
  }

  Future<List<PhoneNumber>> getAvailablePhoneNumbers(Function(bool) isLoading,
      {String areaCode = '',
      int pageSize = 20,
      bool smsEnabled = true,
      bool voiceEnabled = true}) async {
    isLoading(true);
    List<PhoneNumber> phoneNumbers = [];
    await _networkHelper.getRequest(
        '$_searchphoneNumberUrl?SmsEnabled=$smsEnabled&VoiceEnabled=$voiceEnabled&AreaCode=$areaCode&PageSize=$pageSize',
        (response, statusCode, data) {
      print('$response, $statusCode, $data');
      for (var number in data['available_phone_numbers']) {
        phoneNumbers.add(PhoneNumber(
            friendlyName: number['friendly_name'],
            phoneNumber: number['phone_number']));
      }
      isLoading(false);
    }, headers: headers);
    return phoneNumbers;
  }

  Future<List<PhoneNumber>> getActivePhoneNumbers(
    Function(bool) isLoading,
  ) async {
    isLoading(true);
    List<PhoneNumber> phoneNumbers = [];
    await _networkHelper.getRequest('$_activeNumbersUrl?PageSize=20',
        (response, statusCode, data) {
      // print('$response, $statusCode, $data');
      for (var number in data['incoming_phone_numbers']) {
        print(number['sms_application_sid']);
        phoneNumbers.add(PhoneNumber(
            friendlyName: number['friendly_name'],
            phoneNumber: number['phone_number'],
            pnSID: number['sid'],
            uri: number['uri']));
      }
      isLoading(false);
    }, headers: headers);
    return phoneNumbers;
  }

  Future<void> configureActiveNumber(String uri,
      {Function(bool, int, dynamic) requestResponse}) async {
    await _networkHelper.postRequest(
      '$_baseUri$uri',
      headers,
      {
        'Parameters': jsonEncode(
          <String, String>{},
        ),
        'SmsUrl':
            'https://webhooks.twilio.com/v1/Accounts/${this._auth['accountSid']}/Flows/${flow.sid}'
      },
      (response, statusCode, data) {
        print('$response, $statusCode, $data');
        requestResponse(response, statusCode, data);
      },
    );
  }

  Future<void> provisionPhoneNumber(Function(bool) isLoading,
      {@required String phoneNumber, @required Function() onDone}) async {
    isLoading(true);
    await _networkHelper.postRequest(
      _provisionphoneNumberUrl,
      headers,
      {
        'Parameters': jsonEncode(
          <String, String>{},
        ),
        'PhoneNumber': phoneNumber
      },
      (response, statusCode, data) async {
        // print('$response, $statusCode, $data');
        PhoneNumber phoneNumber = PhoneNumber(
            friendlyName: data['friendly_name'],
            phoneNumber: data['phone_number'],
            pnSID: data['sid'],
            uri: data['uri']);
        print('Phone Number Created: $statusCode and now Configuring SMS...');
        await configureActiveNumber(phoneNumber.uri,
            requestResponse: (res, statusCode, data) {
          print('SMS Configured : $statusCode');
          onDone();
        });
        isLoading(false);
      },
    );
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

    _networkHelper.postRequest(_url, headers, body,
        (response, statusCode, data) => print('$response $statusCode, $data'));
  }

  Future sendMediaSMS(
      {@required String toNumber,
      @required String messageBody,
      @required String mediaUrl}) async {
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
      'Body': this._messageBody,
      'MediaUrl': mediaUrl
    };

    _networkHelper.postRequest(_url, headers, body,
        (response, statusCode, data) => print('$response $statusCode, $data'));
  }

  changeTwilioNumber(String twilioNumber) {
    this._twilioNumber = twilioNumber;
  }

  // sendWhatsApp(
  //     {@required String toNumber, @required String messageBody}) async {
  //   String cred = this._auth['cred'];
  //   this._toNumber = toNumber;
  //   this._messageBody = messageBody;
  //   var bytes = utf8.encode(cred);
  //   var base64Str = base64.encode(bytes);
  //   var headers = {
  //     'Authorization': 'Basic $base64Str',
  //     'Accept': 'application/json'
  //   };
  //   var body = {
  //     'From': 'whatsapp:' + this._twilioNumber,
  //     'To': 'whatsapp:' + this._toNumber,
  //     'Body': this._messageBody
  //   };

  //   _networkHelper.postMessageRequest(_url, headers, body);
  // }

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

class PhoneNumber {
  String friendlyName;
  String phoneNumber;
  String pnSID;
  String uri;
  PhoneNumber(
      {@required this.friendlyName,
      @required this.phoneNumber,
      this.pnSID,
      this.uri});
}
