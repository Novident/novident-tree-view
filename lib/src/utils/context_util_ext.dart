import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

const double _defaultMultiplierToHeight = 0.70;

@internal
extension DefaulSize on BuildContext {
  double defaultWidgetSize() {
    return MediaQuery.sizeOf(this).height * _defaultMultiplierToHeight;
  }
}

extension GlobalPaintBounds on BuildContext {
  /// Get the global offset of a widget
  (Offset, RenderObject)? get globalOffsetOfWidget {
    RenderObject? renderObject = findRenderObject();
    Vector3? translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return (Offset(translation.x, translation.y), renderObject!);
    } else {
      return null;
    }
  }
}
