import 'package:flutter/foundation.dart';

class PlatformDetails {
  static final PlatformDetails _singleton = PlatformDetails._internal();

  factory PlatformDetails() {
    return _singleton;
  }

  PlatformDetails._internal();

  bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows;

  bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  bool get isWeb => kIsWeb;
}
