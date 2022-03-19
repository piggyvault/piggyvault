import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/models/login_information_result.dart';

import 'package:piggy_flutter/repositories/repositories.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.userRepository})
      : assert(userRepository != null),
        super(AuthUninitialized());

  final UserRepository userRepository;

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStarted) {
      initOnesignal();
      final bool isFirstAccess = await userRepository.isFirstAccess();
      if (isFirstAccess) {
        yield FirstAccess();
      } else {
        final bool hasToken = await userRepository.hasToken();
        if (hasToken) {
          final LoginInformationResult? result =
              await userRepository.getCurrentLoginInformation();
          if (result == null || result.user == null || result.user!.id == null) {
            yield AuthUnauthenticated();
          } else {
            yield AuthAuthenticated(user: result.user, tenant: result.tenant);
          }
        } else {
          yield AuthUnauthenticated();
        }
      }
    }

    if (event is LoggedIn) {
      yield AuthLoading();
      await userRepository.persistToken(event.token!);

      try {
        await OneSignal.shared
            .sendTag('tenancyName', event.tenancyName.trim().toLowerCase());
      } catch (e) {
        // print(e);
      }

      final LoginInformationResult? result =
          await userRepository.getCurrentLoginInformation();
      if (result == null || result.user == null || result.user!.id == null) {
        yield AuthUnauthenticated();
      } else {
        yield AuthAuthenticated(user: result.user, tenant: result.tenant);
      }
    }

    if (event is LoggedOut) {
      yield AuthLoading();

      try {
        await OneSignal.shared.deleteTag('tenancyName');
      } catch (error) {
        // print(error);
      }
      await userRepository.deleteToken();
      yield AuthUnauthenticated();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initOnesignal() {
    try {
      // TODO(abhith) : use secrets
      OneSignal.shared.setAppId('9bf198c9-442b-4619-b5c9-759fc250f15b');
    } catch (error) {
      print(error);
    }
  }
}
