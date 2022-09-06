import 'package:webview_auth_tizen/oauth/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:collection';

import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'dart:convert';

abstract class OAuthProviderPage extends StatelessWidget {
  final String host;
  final String path;

  final String redirectUri;

  static const String scheme = 'https';
  static const String userAgent = 'Chrome/81.0.0.0 Mobile'; // UA

  final Completer<Map<String, String>> redirectUriReturned = Completer();

  OAuthProviderPage({
    required this.host,
    required this.path,
    required this.redirectUri,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryParams = buildQueryParams();

    final queryParamsString = StringBuffer();

    for (final key in queryParams.keys) {
      queryParamsString.write('&$key=${queryParams[key]}');
    }

    String baseUrl = '$scheme://$host$path';

    final authUrl = '$baseUrl?'
        '$queryParamsString';

    return WebView(
      userAgent: userAgent,
      initialUrl: authUrl,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (request) {
        final url = request.url;

        if (url.startsWith(redirectUri)) {
          final returnedData = _getQueryParams(url);
          redirectUriReturned.complete(returnedData);
        }

        return NavigationDecision.navigate;
      },
    );
  }

  Future<AuthResult> get authResult;

  Map<String, String> buildQueryParams();

  Map<String, String> _getQueryParams(String url) {
    final urlParams = url.split(RegExp('[?&# ]'));
    final Map<String, String> queryParams = HashMap();
    List<String> parts;

    for (final param in urlParams) {
      if (param.contains('=')) {
        parts = param.split('=');
        queryParams[parts[0]] = Uri.decodeFull(parts[1]);
      }
    }

    return queryParams;
  }
}

//ignore: must_be_immutable
class GoogleLoginPage extends OAuthProviderPage {
  final String clientID;
  final String state;
  final String scope;

  GoogleLoginPage({
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

//ignore: must_be_immutable
class GithubLoginPage extends OAuthProviderPage {
  final String clientID;
  final String state;
  final String scope;

  static const kAccessTokenPath = '/login/oauth/access_token';
  static const host_ = 'github.com';
  static const path_ = '/login/oauth/authorize';
  static const responseType_ = 'token id_token';

  String clientSecret;

  GithubLoginPage({
    required this.clientID,
    required this.state,
    required this.scope,
    required super.redirectUri,
    required this.clientSecret,
    super.key,
  }) : super(
          host: host_,
          path: path_,
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

    if (authResult.code == null) {
      throw Exception('github did not return code!');
    }

    final result = await post(kAccessTokenPath, {
      'client_id': clientID,
      'client_secret': clientSecret,
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

  @override
  Map<String, String> buildQueryParams() {
    return {
      'client_id': clientID,
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': state,
      'response_type': 'id_token',
    };
  }
}
