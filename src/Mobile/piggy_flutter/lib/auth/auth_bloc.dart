import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:piggy_flutter/auth/auth.dart';

import 'package:piggy_flutter/repositories/repositories.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({@required this.userRepository}) : assert(userRepository != null);

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStarted) {
      initOnesignal();
      final bool hasToken = await userRepository.hasToken();
      if (hasToken) {
        final user = await userRepository.getCurrentLoginInformation();
        if (user == null || user.id == null) {
          yield AuthUnauthenticated();
        } else {
          yield AuthAuthenticated();
        }
      } else {
        yield AuthUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthLoading();
      await userRepository.persistToken(event.token);
      _handleSendTags(event.tenancyName);
      yield AuthAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthLoading();
      await userRepository.deleteToken();
      yield AuthUnauthenticated();
    }
  }

  void _handleSendTags(String tenancyName) {
    try {
      // print("Sending tags");
      OneSignal.shared
          .sendTag("tenancyName", tenancyName.trim().toLowerCase())
          .then((response) {
        // print("Successfully sent tags with response: $response");
      }).catchError((error) {
        // print("Encountered an error sending tags: $error");
      });
    } catch (e) {}
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initOnesignal() {
    OneSignal.shared.init("9bf198c9-442b-4619-b5c9-759fc250f15b", iOSSettings: {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.inAppLaunchUrl: true
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    // OneSignal.shared.setLogLevel(OSLogLevel.warn, OSLogLevel.none);
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      // print(
      //     "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}");
    });
  }
}
