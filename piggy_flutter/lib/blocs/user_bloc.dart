import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/user.dart';
import 'package:piggy_flutter/services/auth_service.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal/onesignal.dart';

class UserBloc implements BlocBase {
  final AuthService _authService = AuthService();

  final _tenancyName = BehaviorSubject<String>();
  final _usernameOrEmailAddress = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _isAuthenticating = BehaviorSubject<bool>();
  final _isAuthenticated = BehaviorSubject<bool>();

  final _user = BehaviorSubject<User>();
  final _userRefresh = PublishSubject<bool>();

  User loggedinUser;

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

  Stream<User> get user => _user.stream;

  // add data to stream
  Function(bool) get userRefresh => _userRefresh.sink.add;

  Function(String) get changeTenancyName => _tenancyName.sink.add;

  Function(String) get changeUsernameOrEmailAddress =>
      _usernameOrEmailAddress.sink.add;

  Function(String) get changePassword => _password.sink.add;

  UserBloc() {
    _userRefresh.stream.listen(refresh);
  }

  refresh(bool done) {
//    print("########## UserBloc refresh");
    _authService.getCurrentLoginInformation().then((user) {
      loggedinUser = user;
      _user.add(user);
    });
  }

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
        _handleSendTags(validTenancyName);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(UIData.authToken, token);
        _isAuthenticated.add(true);
      }
      _isAuthenticating.sink.add(false);
    });
  }

  void _handleSendTags(String tenancyName) {
    // print("Sending tags");
    OneSignal.shared
        .sendTag("tenancyName", tenancyName.trim().toLowerCase())
        .then((response) {
      // print("Successfully sent tags with response: $response");
    }).catchError((error) {
      // print("Encountered an error sending tags: $error");
    });
  }

  void _handleDeleteTag() {
    // print("Deleting tag");
    OneSignal.shared.deleteTag("tenancyName").then((response) {
      // print("Successfully deleted tags with response $response");
    }).catchError((error) {
      // print("Encountered error deleting tag: $error");
    });
  }

  logout() async {
    _handleDeleteTag();
    await _authService.onLogout();
  }

  void dispose() {
    _tenancyName.close();
    _usernameOrEmailAddress.close();
    _password.close();
    _isAuthenticating.close();
    _isAuthenticated.close();
    _userRefresh.close();
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
