# webview_auth_tizen

Plugin allowing users to log in via OAuth2 protocol. 

## Usage

In order to use the plugin user has to add dependencies in pubspec.yaml
```yaml
webview_auth_tizen: ^1.0.0
```


Then use one of predefined widgets:
```dart
GoogleLoginPage(
	clientID: 'google_client_id',
	state: 'profile',
	scope:
	'https://www.googleapis.com/auth/userinfo.email',
	redirectUri: 'redirect_uri',
);
```

Once the login is done, the future `OAuthProviderPage::getAuthData` is completed.

```dart
final authData = await loginPage.getAuthData();
```

`AuthResult` object obtained in this way contains necessary data for OAuth flow.



### Supported providers
- [x] Google
- [x] Github
- [ ] Facebook
- [ ] Twitter

