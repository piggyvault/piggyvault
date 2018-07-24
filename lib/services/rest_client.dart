import 'dart:async';
import 'dart:convert';
import 'package:piggy_flutter/services/network_service_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piggy_flutter/utils/uidata.dart';

class RestClient {

  Future<MappedNetworkServiceResponse<T>> getAsync<T>(
      String resourcePath) async {
    var response = await http.get(resourcePath);
    return processResponse<T>(response);
  }

  Future<MappedNetworkServiceResponse<T>> postAsync<T>(
      String resourcePath, dynamic data) async {

    final prefs = await SharedPreferences.getInstance();
    var token=  prefs.getString(UIData.authToken);

    var content = json.encoder.convert(data);
    var response =
    await http.post('http://piggyvault.in/api/$resourcePath', body: content, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    return processResponse<T>(response);
  }

  MappedNetworkServiceResponse<T> processResponse<T>(http.Response response) {
    if (!((response.statusCode < 200) ||
        (response.statusCode >= 300) ||
        (response.body == null))) {
      var jsonResult = response.body;
      dynamic resultClass = jsonDecode(jsonResult);

      return new MappedNetworkServiceResponse<T>(
          mappedResult: resultClass,
          networkServiceResponse: new NetworkServiceResponse<T>(success: true));
    } else {
      var errorResponse = response.body;
      return new MappedNetworkServiceResponse<T>(
          networkServiceResponse: new NetworkServiceResponse<T>(
              success: false,
              message: "(${response.statusCode}) ${errorResponse.toString()}"));
    }
  }
}