import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

extension GlobalPaintBounds on BuildContext {
  /// Get the global offset of a widget
  Offset? get globalPaintBounds {
    final RenderObject? renderObject = findRenderObject();
    final Vector3? translation =
        renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final Offset offset = Offset(translation.x, translation.y);
      return offset;
    } else {
      return null;
    }
  }
}

extension PlatformGlobalUtil on BuildContext {
  bool isDesktop({bool supportedWeb = false}) {
    final isDesktop =
        Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    if (supportedWeb) {
      return kIsWeb || isDesktop;
    }
    return isDesktop;
  }

  bool isMobile({bool supportedWeb = false}) {
    final isMobile = Platform.isIOS || Platform.isAndroid;
    if (supportedWeb) {
      return kIsWeb || isMobile;
    }
    return isMobile;
  }
}
