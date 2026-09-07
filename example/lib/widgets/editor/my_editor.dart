import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';
import '../../spell_check/hunspell_spell_checker.dart';
import '../../spell_check/spell_check_context_menu.dart';
import 'document_session.dart';
import 'editor_configuration.dart';
import 'visible_block_wrapper.dart';

/// The Novident Editor surface shared by every view of the app (split
/// view panes, the zen view and the mobile view).
///
/// Vim mode is always wired in (its shortcuts take precedence over the
/// standard ones); when a [ZenModeController] is provided the zen visuals
/// (block dimming, ignored colors) are enabled too, and when a
/// [TypewriterScrollStrategy] is provided the cursor stays vertically
/// centered (typewriter scrolling).
class MyEditor extends StatelessWidget {
  const MyEditor({
    super.key,
    required this.session,
    this.zenController,
    this.typewriterStrategy,
    this.styles,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
    this.autoFocus = false,
    this.footer,
    this.showVisibleBlocks = false,
  });

  final DocumentSession session;

  /// When non-null the editor renders with the zen visuals (block dimming,
  /// ignored colors).
  final ZenModeController? zenController;

  /// When non-null the editor keeps the cursor vertically centered
  /// (typewriter scrolling) via a [TypewriterScrollStrategy].
  final TypewriterScrollStrategy? typewriterStrategy;

  final NovidentStylesConfig? styles;

  final EdgeInsets padding;
  final bool autoFocus;

  /// Extra space after the last block (lets the zen view center the
  /// final paragraphs).
  final Widget? footer;

  /// When true, every top-level block paints a translucent green background
  /// while it is within the editor's visible range (see [VisibleBlockWrapper]).
  final bool showVisibleBlocks;

  @override
  Widget build(BuildContext context) {
    return NovidentEditor(
      editorState: session.editorState,
      editorScrollController: session.scrollController,
      focusNode: session.focusNode,
      autoFocus: autoFocus,
      enableAutoComplete: true,
      showMagnifier: UniversalPlatform.isMobile,
      scrollStrategies: session.zenController?.value.enabled == true &&
              typewriterStrategy != null
          ? [typewriterStrategy!]
          : const [],
      keyboardStrategies: [
        VimStrategy(
          session.vimController,
        ),
        DefaultEditorStrategy(
          commandShortcutEvents: [
            // vim shortcuts must come first so they take precedence.
            ...session.vimController.commandShortcutEvents,
            ...tableCommands,
            ...standardCommandShortcutEvents,
          ],
          characterShortcutEvents: standardCharacterShortcutEvents,
        ),
      ],
      // The mobile surface needs the mobile style: `EditorStyle.desktop`
      // hardcodes `magnifierSize = Size.zero` (and zero-sized drag
      // handles), which makes the magnifier invisible on Android.
      editorStyle: UniversalPlatform.isMobile
          ? EditorStyle.mobile(
              padding: padding,
              firstLineIndent: 20,
              cursorColor: kEditorAccent,
              selectionColor: kEditorSelection,
              dragHandleColor: kEditorAccent.withAlpha(255),
              enableHapticFeedbackOnAndroid: false,
              spellChecker: HunspellSpellChecker.instance,
            )
          : EditorStyle.desktop(
              padding: padding,
              firstLineIndent: 20,
              cursorColor: kEditorAccent,
              selectionColor: kEditorSelection,
              selectionRenderer: VimSelectionRenderer(
                controller: session.vimController,
              ),
              spellChecker: HunspellSpellChecker.instance,
            ),
      blockWrapper: (zenController != null || showVisibleBlocks)
          ? _buildBlockWrapper
          : null,
      footer: footer,
      styles: styles,
      contextMenuBuilder: (context, position, editorState, onPressed) {
        if (EditorPlatform.isMobile) {
          return ContextMenu(
            position: position,
            editorState: editorState,
            items: standardContextMenuItems,
            onPressed: onPressed,
          );
        }
        return buildSpellCheckContextMenu(
          context: context,
          position: position,
          editorState: editorState,
          onPressed: onPressed,
          checker: HunspellSpellChecker.instance,
        );
      },
    );
  }

  /// Composes the block wrappers: the zen dimming (if enabled) is applied
  /// first, then the visible-block highlight is painted on top (outside), so
  /// the green background is not affected by the zen opacity.
  Widget _buildBlockWrapper(
    BuildContext context, {
    required Node node,
    required Widget child,
  }) {
    var wrapped = child;
    if (zenController != null) {
      wrapped =
          zenController!.blockWrapper(context, node: node, child: wrapped);
    }
    if (showVisibleBlocks) {
      wrapped = VisibleBlockWrapper(
        scrollController: session.scrollController,
        node: node,
        child: wrapped,
      );
    }
    return wrapped;
  }
}
