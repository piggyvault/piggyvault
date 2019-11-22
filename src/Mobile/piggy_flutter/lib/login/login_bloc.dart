import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/login/login.dart';
import 'package:piggy_flutter/repositories/repositories.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  LoginBloc({@required this.userRepository, @required this.authBloc})
      : assert(userRepository != null),
        assert(authBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          tenancyName: event.tenancyName,
          usernameOrEmailAddress: event.username,
          password: event.password,
        );

        authBloc.add(LoggedIn(token: token, tenancyName: event.tenancyName));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(errorMessage: error.toString());
      }
    }
  }

  // final _tenancyName = BehaviorSubject<String>();
  // Stream<String> get tenancyName =>
  //     _tenancyName.stream.transform(validateTenancyName);
  // Function(String) get changeTenancyName => _tenancyName.sink.add;

  // final _usernameOrEmailAddress = BehaviorSubject<String>();
  // Stream<String> get usernameOrEmailAddress =>
  //     _usernameOrEmailAddress.stream.transform(validateUsernameOrEmailAddress);
  // Function(String) get changeUsernameOrEmailAddress =>
  //     _usernameOrEmailAddress.sink.add;

  // final _password = BehaviorSubject<String>();
  // Stream<String> get password => _password.stream.transform(validatePassword);
  // Function(String) get changePassword => _password.sink.add;

  // Stream<bool> get submitValid => Observable.combineLatest3(
  //     tenancyName, usernameOrEmailAddress, password, (t, u, p) => true);

  // final _state = BehaviorSubject<ApiRequest>();
  // Stream<ApiRequest> get state => _state.stream;

  // submit() async {
  //   ApiRequest request = ApiRequest(isInProcess: true);
  //   _state.add(request);
  //   request.type = ApiType.login;

  //   final validTenancyName = _tenancyName.value;
  //   final validPassword = _password.value;
  //   final validUsernameOrEmailAddress = _usernameOrEmailAddress.value;

  //   var result = await _authService.authenticate(LoginInput(
  //       tenancyName: validTenancyName,
  //       usernameOrEmailAddress: validUsernameOrEmailAddress,
  //       password: validPassword));

  //   if (result.result != null) {
  //     _handleSendTags(validTenancyName);
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(UIData.authToken, result.result["accessToken"]);
  //   }
  //   request.response = result;
  //   request.isInProcess = false;
  //   _state.add(request);
  // }

  // final validateTenancyName = StreamTransformer<String, String>.fromHandlers(
  //     handleData: (tenancyName, sink) {
  //   if (tenancyName == null) {
  //     sink.addError('Enter a valid family name');
  //   } else if (tenancyName.contains(' ')) {
  //     sink.addError('Family name cannot contain spaces');
  //   } else {
  //     sink.add(tenancyName);
  //   }
  // });

  // final validateUsernameOrEmailAddress =
  //     StreamTransformer<String, String>.fromHandlers(
  //         handleData: (username, sink) {
  //   if (username == null) {
  //     sink.addError('Enter a valid username');
  //   } else if (username.contains(' ')) {
  //     sink.addError('Username cannot contain spaces');
  //   } else {
  //     sink.add(username);
  //   }
  // });

  // final validatePassword = StreamTransformer<String, String>.fromHandlers(
  //     handleData: (password, sink) {
  //   if (password.length >= 6) {
  //     sink.add(password);
  //   } else {
  //     sink.addError('Password must be at least 6 characters');
  //   }
  // });

  // void dispose() {
  //   _tenancyName?.close();
  //   _usernameOrEmailAddress?.close();
  //   _password?.close();
  //   _state?.close();
  // }
}
