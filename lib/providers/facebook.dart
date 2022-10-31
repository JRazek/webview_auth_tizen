import 'package:flutter/material.dart';
import 'package:webview_auth_tizen/auth_data.dart';
import 'package:webview_auth_tizen/oauth2.dart';

import 'dart:async';

import 'package:webview_auth_tizen/util.dart';

class FacebookLoginPage extends OAuthProviderPage {
  final String clientID;

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

  static Future<AuthResult> signIn(
    String clientID,
    String redirectUri,
    BuildContext context,
  ) async {
    final loginPage = FacebookLoginPage(
      clientID: clientID,
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
      'response_type': 'token',
    };
  }
}
