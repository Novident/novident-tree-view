import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';

import 'editor_configuration.dart';

/// Compact vim mode indicator for the editor status bars: a colored dot
/// plus the mode label (and the pending `d` operator when armed).
class VimModeChip extends StatelessWidget {
  const VimModeChip({super.key, required this.controller});

  final VimModeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, _) {
        if (!controller.enabled) {
          return const SizedBox.shrink();
        }
        final (String label, Color color) = switch (controller.mode) {
          VimMode.normal => ('NORMAL', Colors.grey.shade700),
          VimMode.insert => ('INSERT', kEditorAccent),
          VimMode.visual => ('VISUAL', Colors.orange.shade700),
        };
        final String? pending = controller.pendingCommandBuffer;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              pending == null ? label : '$label · $pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}
