import 'dart:collection';
import 'package:webview_flutter/webview_flutter.dart';
import 'auth_data.dart';

import 'dart:async';

/// This class contains [OAuth] data and
/// functionality. It has one public method
/// that returns a [WebView] which has been set up
/// for OAuth 2.0 Authentication.
class OAuth {
  // ignore: public_member_api_docs
  OAuth({
    required this.host,
    required this.path,
    required this.clientID,
    required this.redirectUri,
    this.state,
    required this.scope,
    this.responseType,
    this.otherQueryParams = const {},
  });

  static const String scheme = 'https';
  final String host; // OAuth host
  final String path; // OAuth path
  final String clientID; // OAuth clientID
  final String? responseType; // OAuth responseType
  final String redirectUri; // OAuth redirectUri
  final String? state; // OAuth state
  final String scope; // OAuth scope
  final Map<String, String> otherQueryParams;

  WebView? webview;

  final Completer<AuthResult> _completer = Completer();

  Completer<AuthResult> get completer {
    return _completer;
  }

  Future<AuthResult> get authResult {
    return _completer.future;
  }

  static const String tokenKey = 'access_token'; // OAuth token key
  static const String idToken = 'id_token'; // OpenID id token
  static const String codeKey = 'code'; // OAuth code key
  static const String stateKey = 'state'; // OAuth state key
  static const String scopeKey = 'scope'; // OAuth scope key
  static const String clientIdKey = 'clientID'; // custom client id key
  static const String redirectUriKey = 'redirectURI'; // custom redirect uri key
  static const String userAgent = 'Chrome/81.0.0.0 Mobile'; // UA

  /// Sets up a [WebView] for OAuth authentication.
  /// completed successfully.
  WebView authenticate({
    bool clearCache = false,
  }) {
    final responseTypeQuery = '&response_type=${responseType ?? 'id_token'}';
    final otherParams = StringBuffer();

    for (final key in otherQueryParams.keys) {
      otherParams.write('&$key=${otherQueryParams[key]}');
    }

    String baseUrl = '$scheme://$host$path';

    final authUrl = '$baseUrl?'
        '&client_id=${Uri.encodeComponent(clientID)}'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '${state != null ? "&state=${Uri.encodeComponent(scope)}" : ""}'
        '&scope=${Uri.encodeComponent(scope)}'
        '$responseTypeQuery'
        '$otherParams';

    return webview = WebView(
      onWebViewCreated: (controller) async {
        if (clearCache) {
          final cookieManager = CookieManager();
          await cookieManager.clearCookies();
          await controller.clearCache();
        }
      },
      userAgent: userAgent,
      initialUrl: authUrl,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: _getNavigationDelegate,
    );
  }

  /// Returns a navigation delegate that attempts
  /// to match the redirect url whenever the browser
  /// navigates to a new page. Once the redirect url
  NavigationDecision _getNavigationDelegate(NavigationRequest request) {
    final url = request.url;

    if (url.startsWith(redirectUri)) {
      final returnedData = _getQueryParams(url);
      returnedData[clientIdKey] = clientID;
      returnedData[redirectUriKey] = redirectUri;
      returnedData[stateKey] = state!;

      final authResult = AuthResult(
        clientID: clientID,
        accessToken: returnedData[tokenKey],
        idToken: returnedData[idToken],
        code: returnedData[codeKey],
        response: returnedData,
      );

      _completer.complete(authResult);
    }

    return NavigationDecision.navigate;
  }

  /// Parses url query params into a map
  /// @param url: The url to parse.
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
