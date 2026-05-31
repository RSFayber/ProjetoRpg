import 'dart:io';

/// Plataformas suportadas: Windows (desktop) e Android (mobile).
enum AppPlatformKind { windows, android, unsupported }

AppPlatformKind get currentAppPlatform {
  if (Platform.isWindows) {
    return AppPlatformKind.windows;
  }
  if (Platform.isAndroid) {
    return AppPlatformKind.android;
  }
  return AppPlatformKind.unsupported;
}

bool get isSupportedPlatform => currentAppPlatform != AppPlatformKind.unsupported;

bool get isDesktopPlatform => currentAppPlatform == AppPlatformKind.windows;

bool get isMobilePlatform => currentAppPlatform == AppPlatformKind.android;
