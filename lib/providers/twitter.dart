import 'package:webview_auth_tizen/auth_data.dart';
import 'package:webview_auth_tizen/oauth2.dart';

import 'dart:async';

//TODO: (JRazek)
class TwitterLoginPage extends OAuthProviderPage {
  final String clientID;
  final String state;
  final String scope;

  TwitterLoginPage({
    required this.clientID,
    required this.state,
    required this.scope,
    required super.redirectUri,
    super.key,
  }) : super(
          host: 'accounts.google.com',
          path: '/o/oauth2/auth',
        );

  @override
  Future<AuthResult> get authResult async {
    final returnedData = await redirectUriReturned.future;

    returnedData['clientID'] = clientID;
    returnedData['redirectURI'] = redirectUri;

    final authResult = AuthResult(
      clientID: clientID,
      accessToken: returnedData['access_token'],
      idToken: returnedData['id_token'],
      code: returnedData['code'],
      response: returnedData,
    );

    return authResult;
  }

  @override
  Map<String, String> buildQueryParams() {
    return {
      'client_id': clientID,
      'redirect_uri': redirectUri,
      'scope': scope,
      'response_type': 'token id_token',
    };
  }
}
