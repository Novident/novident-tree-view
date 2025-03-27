import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

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
