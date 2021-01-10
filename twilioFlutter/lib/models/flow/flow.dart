import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twilioFlutter/models/flow/execution.dart';
import 'package:twilioFlutter/services/network.dart';

class Flow {
  String sid;
  String twilioNumber;

  List<Execution> executionList;
  dynamic headers;
  NetworkHelper _networkHelper = NetworkHelper();
  Flow({@required this.headers, @required this.sid});

  Future sendAutoReminderRequest(
    Function(bool, int, dynamic) requestResponse, {
    @required String toNumber,
    @required String id,
    @required String clientId,
    @required String firstName,
    @required String message,
    @required String adminUserId,
    @required String flowSID,
  }) async {
    _networkHelper.postRequest(
        'https://studio.twilio.com/v1/Flows/$flowSID/Executions', headers, {
      'Parameters': jsonEncode(
        <String, String>{
          'adminUserId': adminUserId,
          'firstName': firstName,
          'message': '$message',
          'appointmentId': '$id',
          'clientId': '$clientId',
          'from': twilioNumber,
          'to': toNumber,
          'body': message,
          'waitTimer': '7200',
          'onNoMatchReply':
              'We\'re sorry, we couldn\'t understand your response.',
          'onConfirmReply': 'Thank you!',
          'onRescheduleReply':
              'We understand that plans change. Thanks for letting us know! Someone will be reaching out to you to reschedule!',
          'onNoReply':
              'Unfortunately we did not recieve a reply from you. Someone will be contacting you soon.'
        },
      ),
      'From': twilioNumber,
      'To': toNumber,
    }, (response, statusCode, data) {
      requestResponse(response, statusCode, data);
    });
  }

  Future<void> _fetchExecution(String executionSID,
      {Function(Execution) onExecution,
      Function(bool, int, dynamic) requestResponse}) async {
    return await _networkHelper.getRequest(
        'https://studio.twilio.com/v1/Flows/$sid/Executions/$executionSID',
        (response, statusCode, data) {
      // print('$response, $statusCode, $data');
      requestResponse(response, statusCode, data);
      return onExecution(Execution(
          sid: data['sid'],
          flowSID: data['flow_sid'],
          status: data['status'] == 'active'
              ? ExecutionStatus.active
              : ExecutionStatus.ended));
    }, headers: headers);

    // print(data);
  }

  Future<void> endActiveExecution(String executionSID,
      {Function() isActive}) async {
    return _fetchExecution(executionSID, onExecution: (execution) async {
      if (execution.status == ExecutionStatus.active) {
        isActive();

        return await _networkHelper.postRequest(
            'https://studio.twilio.com/v1/Flows/$sid/Executions/$executionSID',
            headers, {
          'Parameters': jsonEncode(
            <String, String>{},
          ),
          'Status': 'ended'
        }, (response, statusCode, data) {
          print('done!');
          print(data['status']);
        });
      } else {
        print('status: ${execution.status}');
      }
    }, requestResponse: (response, statusCode, data) {});
  }
}
