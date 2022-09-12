import 'dart:collection';
import 'package:webview_flutter/webview_flutter.dart';
import 'auth_data.dart';
import 'package:flutter/widgets.dart';

import 'dart:async';

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
