import 'package:desktop_webview_auth_tizen/oauth/auth-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'oauth/oauth2.dart';
import 'dart:async';

//const redirectUri =
//    'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler';

abstract class OAuthProviderPage extends StatelessWidget {
  final Function(AuthData)? callback;

  final String host;
  final String path;
  final String responseType;

  final String clientID;
  final String state;
  final String scope;

  final String redirectUri;

  final Completer<AuthData> _completer = Completer();

  OAuthProviderPage({
    required this.host,
    required this.path,
    required this.responseType,
    required this.clientID,
    required this.state,
    required this.scope,
	required this.redirectUri,
    this.callback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuth(
      host: host,
      path: path,
      clientID: clientID,
      redirectUri: redirectUri,
      state: state,
      scope: scope,
      responseType: responseType,
    ).authenticate(
      onDone: (authData) {
        _completer.complete(authData);
        if (callback != null) {
          callback!(authData);
        }
      },
    );
  }

  Future<AuthData> getAuthData() async {
    return _completer.future;
  }
}

//ignore: must_be_immutable
class GoogleLoginPage extends OAuthProviderPage {
  GoogleLoginPage({
    required super.clientID,
    required super.state,
    required super.scope,
	required super.redirectUri,
    super.callback,

    super.key,
  }) : super(
          host: 'accounts.google.com',
          path: '/o/oauth2/auth',
          responseType: 'token id_token',
        );
}
