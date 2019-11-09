import 'dart:async';

import 'package:piggy_flutter/blocs/bloc_provider.dart';
import 'package:piggy_flutter/models/user.dart';
import 'package:piggy_flutter/services/auth_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserBloc implements BlocBase {
  final AuthService _authService = AuthService();

  final _user = BehaviorSubject<User>();
  Stream<User> get user => _user.stream;

  final _userRefresh = PublishSubject<bool>();
  Function(bool) get userRefresh => _userRefresh.sink.add;

  UserBloc() {
    _userRefresh.stream.listen(refresh);
  }

  refresh(bool done) {
//    print("########## UserBloc refresh");
    _authService.getCurrentLoginInformation().then((user) {
      _user.add(user);
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
    _userRefresh.close();
  }
}
