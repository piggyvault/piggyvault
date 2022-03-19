import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/models/models.dart';
import 'package:piggy_flutter/repositories/piggy_api_client.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final PiggyApiClient piggyApiClient;

  UserRepository({required this.piggyApiClient})
      : assert(piggyApiClient != null);

  Future<String?> authenticate(
      {required String tenancyName,
      required String usernameOrEmailAddress,
      required String password}) async {
    final isTenantAvailableResult =
        await piggyApiClient.isTenantAvailable(tenancyName);

    if (isTenantAvailableResult.state == 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(UIData.tenantId, isTenantAvailableResult.tenantId!);

      final authenticateResult = await piggyApiClient.authenticate(
          usernameOrEmailAddress: usernameOrEmailAddress, password: password);

      return authenticateResult.accessToken;
    }

    // TODO: handle invalid tenant cases
    return null;
  }

  Future<LoginInformationResult?> getCurrentLoginInformation() async {
    return await piggyApiClient.getCurrentLoginInformations();
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(UIData.authToken);

    return token != null;
  }

  Future<bool> isFirstAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(UIData.firstAccess) ?? true;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(UIData.authToken);
    await prefs.remove(UIData.tenantId);
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(UIData.authToken, token);
    return;
  }

  Future<UserSettings> getUserSettings() async {
    return await piggyApiClient.getUserSettings();
  }

  Future<void> changeDefaultCurrency(String currencyCode) async {
    return await piggyApiClient.changeDefaultCurrency(currencyCode);
  }
}
