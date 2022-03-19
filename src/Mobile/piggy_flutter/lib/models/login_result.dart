class LoginResult {
  final String? accessToken;

  const LoginResult({this.accessToken});

  static LoginResult fromJson(dynamic json) {
    return LoginResult(accessToken: json['accessToken']);
  }
}
