import 'dart:async';

import 'package:piggy_flutter/services/auth_service.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBloc {
  final AuthService _authService = AuthService();

  final _tenancyName = BehaviorSubject<String>();
  final _usernameOrEmailAddress = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _isAuthenticating = BehaviorSubject<bool>();
  final _isAuthenticated = BehaviorSubject<bool>();

// retrieve data from stream
  Stream<String> get tenancyName =>
      _tenancyName.stream.transform(validateTenancyName);

  Stream<String> get usernameOrEmailAddress =>
      _usernameOrEmailAddress.stream.transform(validateUsernameOrEmailAddress);

  Stream<String> get password => _password.stream.transform(validatePassword);

  Stream<bool> get isAuthenticating => _isAuthenticating.stream;

  Stream<bool> get isAuthenticated => _isAuthenticated.stream;

  Stream<bool> get submitValid => Observable.combineLatest3(
      tenancyName, usernameOrEmailAddress, password, (t, u, p) => true);

  // add data to stream
  Function(String) get changeTenancyName => _tenancyName.sink.add;

  Function(String) get changeUsernameOrEmailAddress =>
      _usernameOrEmailAddress.sink.add;

  Function(String) get changePassword => _password.sink.add;

  submit() {
    final validTenancyName = _tenancyName.value;
    final validPassword = _password.value;
    final validUsernameOrEmailAddress = _usernameOrEmailAddress.value;

    _isAuthenticating.sink.add(true);

    _authService
        .authenticate(LoginInput(
            tenancyName: validTenancyName,
            usernameOrEmailAddress: validUsernameOrEmailAddress,
            password: validPassword))
        .then((token) async {
      if (token == null) {
        _isAuthenticated.add(false);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(UIData.authToken, token);
        _isAuthenticated.add(true);
      }
      _isAuthenticating.sink.add(false);
    });
  }

  dispose() {
    _tenancyName.close();
    _usernameOrEmailAddress.close();
    _password.close();
    _isAuthenticating.close();
    _isAuthenticated.close();
  }

  final validateTenancyName = StreamTransformer<String, String>.fromHandlers(
      handleData: (tenancyName, sink) {
    if (tenancyName == null) {
      sink.addError('Enter a valid family name');
    } else if (tenancyName.contains(' ')) {
      sink.addError('Family name cannot contain spaces');
    } else {
      sink.add(tenancyName);
    }
  });

  final validateUsernameOrEmailAddress =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (username, sink) {
    if (username == null) {
      sink.addError('Enter a valid username');
    } else if (username.contains(' ')) {
      sink.addError('Username cannot contain spaces');
    } else {
      sink.add(username);
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length >= 6) {
      sink.add(password);
    } else {
      sink.addError('Password must be at least 6 characters');
    }
  });
}
