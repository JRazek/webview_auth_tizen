import 'package:desktop_webview_auth_tizen/oauth/auth-data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'oauth/oauth2.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'dart:convert';

abstract class OAuthProviderPage extends StatelessWidget {
  final Function(AuthResult, Completer<AuthResult>) callback;

  final String host;
  final String path;
  final String responseType;

  final String clientID;
  final String state;
  final String scope;
  final String? clientSecret;

  final String redirectUri;

  final Completer<AuthResult> _completer = Completer();

  OAuthProviderPage({
    required this.host,
    required this.path,
    required this.responseType,
    required this.clientID,
    this.clientSecret,
    required this.state,
    required this.scope,
    required this.redirectUri,
    required this.callback,
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
    ).authenticate(onDone: (authResult) {
      callback(authResult, _completer);
    });
  }

  Future<AuthResult> getAuthData() async {
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
    super.key,
  }) : super(
            host: 'accounts.google.com',
            path: '/o/oauth2/auth',
            responseType: 'token id_token',
            callback: (authResult, completer) {
              completer.complete(authResult);
            });
}

//ignore: must_be_immutable
class GithubLoginPage extends OAuthProviderPage {
  static const kAccessTokenPath = '/login/oauth/access_token';
  static const host_ = 'github.com';
  static const path_ = '/login/oauth/authorize';
  static const responseType_ = 'token id_token';

  GithubLoginPage({
    required super.clientID,
    required super.state,
    required super.scope,
    required super.redirectUri,
    required super.clientSecret,
    super.key,
  }) : super(
            host: host_,
            path: path_,
            responseType: responseType_,
            callback: (authResult, completer) async {
              if (!completer.isCompleted) {
                if (authResult.code == null) {
                  throw Exception('github did not return code!');
                }

                final result = await post(kAccessTokenPath, {
                  'client_id': clientID,
                  'client_secret': clientSecret!,
                  'code': authResult.code!,
                  'redirect_uri': redirectUri,
                });

                if (result == null) throw Exception("Couldn't authroize");

                final decodedRes = json.decode(result);

                authResult.accessToken = decodedRes['access_token'];

                print('counter');

                completer.complete(authResult);
              }
            });

  static Future<String?> post(String path, Map<String, String> params) async {
    final paramsString = StringBuffer();

    for (final key in params.keys) {
      paramsString.write('&$key=${params[key]}');
    }

    var uri =
        Uri(scheme: 'https', host: host_, path: path, queryParameters: params);

    print(uri);

    try {
      final res = await http.post(
        uri,
        headers: {"Accept": "application/json"},
        body: params,
      );

      if (res.statusCode == 200) {
        return res.body;
      } else {
        throw Exception('HttpCode: ${res.statusCode}, Body: ${res.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
