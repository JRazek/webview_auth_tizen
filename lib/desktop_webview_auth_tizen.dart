import 'package:desktop_webview_auth_tizen/oauth/auth-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'oauth/oauth2.dart';
import 'dart:async';

const redirectUri =
    'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler';

//ignore: must_be_immutable
class GoogleLoginPage extends StatelessWidget {
  final Function(AuthData)? callback;

  final String clientID;
  final String state;
  final String scope;

  final Completer<AuthData> _completer = Completer();

  GoogleLoginPage({
	  required this.clientID,
	  required this.state,
	  required this.scope,
	  this.callback, 
	  Key? key,
  }) 
  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OAuth(
      host: 'accounts.google.com',
      path: '/o/oauth2/auth',
      clientID: clientID,
      redirectUri: redirectUri,
      state: state,
      scope: scope,
      responseType: 'token id_token',
    ).authenticate(
      onDone: (authData) {
		_completer.complete(authData);
		if(callback != null){
			callback!(authData);
		}
      },
    );
  }

  Future<AuthData> getAuthData() async{
	return _completer.future;
  }

}
