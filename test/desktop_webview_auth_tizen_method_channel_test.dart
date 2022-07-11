import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_webview_auth_tizen/desktop_webview_auth_tizen_method_channel.dart';

void main() {
  MethodChannelDesktopWebviewAuthTizen platform = MethodChannelDesktopWebviewAuthTizen();
  const MethodChannel channel = MethodChannel('desktop_webview_auth_tizen');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
