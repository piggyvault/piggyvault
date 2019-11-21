import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String token;
  final String tenancyName;

  const LoggedIn({@required this.token, @required this.tenancyName});

  @override
  List<Object> get props => [token];
}

class LoggedOut extends AuthEvent {}

// class GetCurrentLoginInformation extends AuthEvent {
//   const GetCurrentLoginInformation();
// }

// @immutable
// abstract class AuthEvent {
//   Future<AuthState> applyAsync({AuthState currentState, AuthBloc bloc});
//   final AuthRepository _authRepository = AuthRepository();
// }

// class UnAuthEvent extends AuthEvent {
//   @override
//   Future<AuthState> applyAsync({AuthState currentState, AuthBloc bloc}) async {
//     return UnAuthState(0);
//   }
// }

// class LoadAuthEvent extends AuthEvent {
//   final bool isError;
//   @override
//   String toString() => 'LoadAuthEvent';

//   LoadAuthEvent(this.isError);

//   @override
//   Future<AuthState> applyAsync({AuthState currentState, AuthBloc bloc}) async {
//     try {
//       if (currentState is InAuthState) {
//         return currentState.getNewVersion();
//       }
//       await Future.delayed(Duration(seconds: 2));
//       this._authRepository.test(this.isError);
//       return InAuthState(0, "Hello world");
//     } catch (_, stackTrace) {
//       developer.log('$_',
//           name: 'LoadAuthEvent', error: _, stackTrace: stackTrace);
//       return ErrorAuthState(0, _?.toString());
//     }
//   }
// }
