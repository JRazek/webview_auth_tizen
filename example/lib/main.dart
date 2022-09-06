// ignore_for_file: constant_identifier_names

import 'package:webview_auth_tizen/oauth/github.dart';
import 'package:webview_auth_tizen/oauth/google.dart';
import 'package:webview_auth_tizen/oauth/auth_data.dart';
import 'package:webview_auth_tizen/oauth/oauth2.dart';
import 'package:flutter/material.dart';

const googleClientId =
    '448618578101-sg12d2qin42cpr00f8b0gehs5s7inm0v.apps.googleusercontent.com';
const redirectUri =
    'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler';

const githubClientId = '';
const githubClientSecret = '';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

enum LoginStateE { selector, login_page, success }

class LoginState extends State<MyApp> {
  LoginStateE state = LoginStateE.selector;
  AuthResult? authData;
  OAuthProviderPage? loginPage;

  void loginCallback(AuthResult authData) {
    setState(() {
      state = LoginStateE.success;
      this.authData = authData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return state == LoginStateE.login_page
        ? loginPage!
        : MaterialApp(
            theme: ThemeData(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                ),
              ),
            ),
            home: state == LoginStateE.selector
                ? Scaffold(
                    body: Builder(
                      builder: (context) {
                        final buttons = [
                          ElevatedButton(
                            onPressed: () {
                              oauthSignIn(GoogleLoginPage(
                                clientID: googleClientId,
                                state: 'profile',
                                scope:
                                    'https://www.googleapis.com/auth/userinfo.email',
                                redirectUri: redirectUri,
                              ));
                            },
                            child: const Text('Sign in with Google'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              oauthSignIn(GithubLoginPage(
                                clientID: githubClientId,
                                state: 'profile',
                                scope: 'user',
                                redirectUri: redirectUri,
                                clientSecret: githubClientSecret,
                              ));
                            },
                            child: const Text('Sign in with Github'),
                          ),
                        ];

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: ListView.separated(
                              itemCount: buttons.length,
                              shrinkWrap: true,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                return buttons[index];
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Scaffold(body: Builder(builder: (context) {
                    return Text('oauth_token:${authData?.accessToken}');
                  })));
  }

  Future oauthSignIn(OAuthProviderPage page) async {
    loginPage = page;

    setState(() {
      state = LoginStateE.login_page;
    });

    authData = await loginPage!.authResult;

    setState(() {
      state = LoginStateE.success;
    });
  }

  void notify(BuildContext context, String? result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result: $result'),
      ),
    );
  }
}
