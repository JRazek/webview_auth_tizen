import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:desktop_webview_auth/src/provider_args.dart';
import 'package:desktop_webview_auth/src/auth_result.dart';
import 'oauth/oauth2.dart';

class GoogleLoginPage extends StatelessWidget {
  const GoogleLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuth(
      host: 'accounts.google.com',
      path: '/o/oauth2/auth',
      clientID:
          '448618578101-sg12d2qin42cpr00f8b0gehs5s7inm0v.apps.googleusercontent.com',
      redirectUri: 'redirectUrl',
      state: 'profile',
      scope: 'https://www.googleapis.com/auth/userinfo.email',
      responseType: 'token id_token',
    ).authenticate(
      onDone: (data) {
//        print('logged in successfuly!!');
//        final credential = GoogleAuthProvider.credential(
//          idToken: data.idToken,
//        );
//        _auth.signInWithCredential(credential);
        print(data);
      },
    );
  }
}
