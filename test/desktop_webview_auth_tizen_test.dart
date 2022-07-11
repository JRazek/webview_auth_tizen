import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_webview_auth_tizen/desktop_webview_auth_tizen.dart';
import 'package:desktop_webview_auth_tizen/desktop_webview_auth_tizen_platform_interface.dart';
import 'package:desktop_webview_auth_tizen/desktop_webview_auth_tizen_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDesktopWebviewAuthTizenPlatform 
    with MockPlatformInterfaceMixin
    implements DesktopWebviewAuthTizenPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DesktopWebviewAuthTizenPlatform initialPlatform = DesktopWebviewAuthTizenPlatform.instance;

  test('$MethodChannelDesktopWebviewAuthTizen is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDesktopWebviewAuthTizen>());
  });

  test('getPlatformVersion', () async {
    DesktopWebviewAuthTizen desktopWebviewAuthTizenPlugin = DesktopWebviewAuthTizen();
    MockDesktopWebviewAuthTizenPlatform fakePlatform = MockDesktopWebviewAuthTizenPlatform();
    DesktopWebviewAuthTizenPlatform.instance = fakePlatform;
  
    expect(await desktopWebviewAuthTizenPlugin.getPlatformVersion(), '42');
  });
}
