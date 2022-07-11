import 'package:desktop_webview_auth_tizen/oauth/auth-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:desktop_webview_auth/src/provider_args.dart';
import 'package:desktop_webview_auth/src/auth_result.dart';
import 'oauth/oauth2.dart';

const redirectUri =
    'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler';

class GoogleLoginPage extends StatelessWidget {
  final Function(AuthData)? callback;
  const GoogleLoginPage({this.callback, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuth(
      host: 'accounts.google.com',
      path: '/o/oauth2/auth',
      clientID:
          '448618578101-sg12d2qin42cpr00f8b0gehs5s7inm0v.apps.googleusercontent.com',
      redirectUri: redirectUri,
      state: 'profile',
      scope: 'https://www.googleapis.com/auth/userinfo.email',
      responseType: 'token id_token',
    ).authenticate(
      onDone: callback!,
    );
  }
}
