import 'package:webview_auth_tizen/oauth/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'oauth/oauth2.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'dart:convert';

abstract class OAuthProviderPage extends StatelessWidget {
  final String host;
  final String path;
  final String responseType;

  final String clientID;
  final String state;
  final String scope;
  final String? clientSecret;

  final String redirectUri;

  OAuth oauth;

  OAuthProviderPage({
    required this.host,
    required this.path,
    required this.responseType,
    required this.clientID,
    this.clientSecret,
    required this.state,
    required this.scope,
    required this.redirectUri,
    Key? key,
  })  : oauth = OAuth(
          host: host,
          path: path,
          clientID: clientID,
          redirectUri: redirectUri,
          state: state,
          scope: scope,
          responseType: responseType,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return oauth.authenticate();
  }

  Future<AuthResult> get authResult;
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
        );

  @override
  Future<AuthResult> get authResult async {
    return oauth.authResult;
  }
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
        );

  @override
  Future<AuthResult> get authResult async {
    final authResult = await oauth.authResult;

    if (authResult.code == null) {
      throw Exception('github did not return code!');
    }

    final result = await post(kAccessTokenPath, {
      'client_id': clientID,
      'client_secret': clientSecret!,
      'code': authResult.code!,
      'redirect_uri': redirectUri,
    });

    authResult.accessToken = result['access_token'];

    return authResult;
  }

  static Future post(String path, Map<String, String> params) async {
    var uri =
        Uri(scheme: 'https', host: host_, path: path, queryParameters: params);

    final res = await http.post(
      uri,
      headers: {"Accept": "application/json"},
      body: params,
    );

    if (res.statusCode == 200) {
      final decodedRes = json.decode(res.body);

      if (!decodedRes.containsKey('access_token')) {
        throw Exception("Couldn't authroize");
      }

      return decodedRes;
    } else {
      throw Exception('HttpCode: ${res.statusCode}, Body: ${res.body}');
    }
  }
}
