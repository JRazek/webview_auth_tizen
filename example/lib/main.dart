// ignore_for_file: constant_identifier_names

import 'package:webview_auth_tizen/webview_auth_tizen.dart';
import 'package:webview_auth_tizen/oauth/auth-data.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

typedef SignInCallback = Future<void> Function();
const String apiKey = 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0';

const GOOGLE_CLIENT_ID =
    '448618578101-sg12d2qin42cpr00f8b0gehs5s7inm0v.apps.googleusercontent.com';
const REDIRECT_URI =
    'https://react-native-firebase-testing.firebaseapp.com/__/auth/handler';

const GITHUB_CLIENT_ID = '';
const GITHUB_CLIENT_SECRET = '';

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
                                clientID: GOOGLE_CLIENT_ID,
                                state: 'profile',
                                scope:
                                    'https://www.googleapis.com/auth/userinfo.email',
                                redirectUri: REDIRECT_URI,
                              ));
                            },
                            child: const Text('Sign in with Google'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              oauthSignIn(GithubLoginPage(
                                clientID: GITHUB_CLIENT_ID,
                                state: 'profile',
                                scope:
                                    'user',
                                redirectUri: REDIRECT_URI,
								clientSecret: GITHUB_CLIENT_SECRET,
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

    debugPrint(state.toString());

    authData = await loginPage?.getAuthData();

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
