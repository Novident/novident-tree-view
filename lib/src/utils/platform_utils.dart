@internal
library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

// Android

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAndroidApp => !kIsWeb && isAndroid;

// iOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isIosApp => !kIsWeb && isIos;

// Mobile

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMobile =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMobileApp => !kIsWeb && isMobile;

// Destkop

@pragma('vm:platform-const-if', !kDebugMode)
bool get isDesktop =>
    defaultTargetPlatform == TargetPlatform.linux ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isDesktopApp => !kIsWeb && isDesktop;

// windows

@pragma('vm:platform-const-if', !kDebugMode)
bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isWindowsApp => !kIsWeb && isWindows;

// macOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isMacOSApp => !kIsWeb && isMacOS;

// AppleOS

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAppleOS =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

@pragma('vm:platform-const-if', !kDebugMode)
bool get isAppleOSApp => !kIsWeb && isAppleOS;

extension PlatformThemeCheckExtension on ThemeData {
  bool get isMaterial => !isCupertino;
  bool get isCupertino =>
      {TargetPlatform.iOS, TargetPlatform.macOS}.contains(platform);
}
