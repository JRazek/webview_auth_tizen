import 'package:webview_auth_tizen/auth_data.dart';
import 'package:webview_auth_tizen/oauth2.dart';

import 'dart:async';

import 'package:webview_auth_tizen/util.dart';

class FacebookLoginPage extends OAuthProviderPage {
  final String clientID;
  String state = '';

  FacebookLoginPage({
    required this.clientID,
    required super.redirectUri,
    super.key,
  }) : super(
          host: 'www.facebook.com',
          path: '/v12.0/dialog/oauth',
        );

  @override
  Future<AuthResult> get authResult async {
    final returnedData = await redirectUriReturned.future;

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
    state = generateNonce();

    return {
      'client_id': clientID,
      'redirect_uri': redirectUri,
      'state': state,
      'response_type': 'token',
    };
  }
}
