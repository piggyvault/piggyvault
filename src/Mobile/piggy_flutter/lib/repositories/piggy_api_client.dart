import 'package:dio/dio.dart';
import 'package:piggy_flutter/models/isTenantAvailableOutput.dart';

class PiggyApiClient {
  static const baseUrl = 'https://piggyvault.in';
  // static const baseUrl = 'http://10.0.2.2:21021';
  // static const baseUrl = 'http://localhost:21021';
  Dio _dio;

  PiggyApiClient() {
    BaseOptions options = new BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    _dio = new Dio(options);
  }

  Future<IsTenantAvailableOutput> isTenantAvailable(String tenancyName) async {
    final isTenantAvailableResponse = await this._dio.post(
        '/api/services/app/Account/IsTenantAvailable',
        data: {"tenancyName": tenancyName});

    if (isTenantAvailableResponse.statusCode != 200) {
      throw Exception('error getting family');
    }

    return IsTenantAvailableOutput.fromJson(
        isTenantAvailableResponse.data["result"]);
  }
}
