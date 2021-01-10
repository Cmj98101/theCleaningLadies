import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper();

  Future postRequest(
    var url,
    var headers,
    var body,
    Function(bool, int, dynamic) requestResponse,
  ) async {
    http.Response response = await http.post(url, headers: headers, body: body);
    var data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Request Successful statusCode: ${response.statusCode}');
      requestResponse(true, response.statusCode, data);
    } else {
      print('Request Failed statusCode: ${response.statusCode}');
      requestResponse(false, data['code'], data);

      // print('Error Code : ' + data['code'].toString());
      // print('Error Message : ' + data['message']);
      // print("More info : " + data['more_info']);
    }
  }

  Future getRequest(String url, Function(bool, int, dynamic) requestResponse,
      {var headers}) async {
    http.Response response = await http.get(url, headers: headers);
    var data = response.body;

    if (response.statusCode == 200) {
      // print('get request Data $data');
      requestResponse(true, response.statusCode, jsonDecode(data));
      return jsonDecode(data);
    } else {
      requestResponse(false, response.statusCode, jsonDecode(data));

      print(response.statusCode);
    }
  }
}
