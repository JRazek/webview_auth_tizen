/// This class contains the access token and
/// variables that provide easy access to the
/// common properties of a user. It also contains
/// all data from the authentication response and

class AuthData {
  // ignore: public_member_api_docs
  const AuthData({
    required this.clientID,
    this.firstName,
    this.lastName,
    this.userID,
    this.email,
    this.profileImgUrl,
    this.code,
  });

  final String? userID; // User's profile id
  final String? clientID; // OAuth client id
  final String? firstName; // User's first name
  final String? lastName; // User's last name
  final String? email; // User's email
  final String? profileImgUrl; // User's profile image url
  final String? code; // code returned from authorize endpoint
}

class AuthResult {
  String? accessToken;
  String? idToken;
  String? tokenSecret;
  String? code;
  String? clientID;
  Map<String, String> response;

  AuthResult(
      {this.accessToken,
      this.idToken,
      this.tokenSecret,
      this.code,
      this.clientID,
      this.response = const {}});

  @override
  String toString() {
    return 'AuthResult(idToken: $idToken, accessToken: $accessToken, tokenSecret: $tokenSecret)';
  }
}
