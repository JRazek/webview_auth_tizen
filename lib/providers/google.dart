import 'package:flutter/material.dart';
import 'package:webview_auth_tizen/auth_data.dart';
import 'package:webview_auth_tizen/oauth2.dart';

import 'dart:async';

import 'package:webview_auth_tizen/util.dart';

class GoogleLoginPage extends OAuthProviderPage {
  final String clientID;
  final String scope;

  GoogleLoginPage({
    required this.clientID,
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

  static Future<AuthResult> signIn(
    String clientID,
    String scope,
    String redirectUri,
    BuildContext context,
  ) {
    final loginPage = GoogleLoginPage(
      clientID: clientID,
      scope: scope,
      redirectUri: redirectUri,
    );

    showDialog(
      context: context,
      builder: (context) {
        return loginPage;
      },
    );

    final res = loginPage.authResult;

    res.then((value) => Navigator.pop(context));

    return res;
  }

  @override
  Map<String, String> buildQueryParams() {
    var state = generateNonce();

    return {
      'client_id': clientID,
      'redirect_uri': redirectUri,
      'state': state,
      'scope': scope,
      'response_type': 'token id_token',
    };
  }
}
