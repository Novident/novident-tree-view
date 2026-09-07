import 'package:flutter/material.dart';
import 'package:novident_editor/novident_editor.dart';

/// The app's Material 3 seed color — drives the whole color scheme.
/// A deep indigo that reads as calm and professional for a document editor.
const Color kSeedColor = Color(0xFF4F46E5);

/// Workspace colors (shared by the desktop, mobile and zen views).
/// A clean, light neutral that lets the white editor sheets stand out.
const Color kWorkspaceBackground = Color(0xFFF3F4F6);

/// Primary accent: editor cursor, focused pane tint, zen toggle, vim chip
/// and the file/directory selection highlight. Harmonizes with [kSeedColor].
const Color kEditorAccent = Color(0xFF4F46E5);

/// Translucent accent used for text selection highlights.
const Color kEditorSelection = Color(0x334F46E5);

/// Vim emulation is disabled on mobile: its normal mode would suppress
/// the soft keyboard input.
const VimModeConfiguration kMobileVimConfiguration = VimModeConfiguration(
  enabled: false,
);

/// Toolbar shown above the editor on desktop (top of the editor column).
final List<ToolbarItem> kDesktopToolbarItems = <ToolbarItem>[
  styleToolbarItem,
  buildFontSizeItem(),
  buildFontFamilyItem(fontFamilies: getDefaultFonts()),
  ...markdownFormatItems,
  quoteItem,
  bulletedListItem,
  numberedListItem,
  linkItem,
  ...alignmentItems,
];

/// Toolbar shown above the soft keyboard on mobile (bottom of the
/// editor column).
///
/// Same feature set as [kDesktopToolbarItems] expressed through the
/// mobile item system: style, text decoration, headings, todo lists,
/// lists, link, quote and code. Font size, font family and alignment
/// have no mobile counterpart widgets yet, so they are omitted.
final List<MobileToolbarItem> kMobileToolbarItems = <MobileToolbarItem>[
  headingMobileToolbarItem,
  styleMobileToolbarItem,
  textDecorationMobileToolbarItemV2,
  codeMobileToolbarItem,
  linkMobileToolbarItem,
  buildTextAndBackgroundColorMobileToolbarItem(),
  listMobileToolbarItem,
  todoListMobileToolbarItem,
  quoteMobileToolbarItem,
  blocksMobileToolbarItem,
  dividerMobileToolbarItem,
];

/// Editor styles shared by every editor surface of the app (desktop
/// panes, the mobile editor and their toolbars).
final NovidentStylesConfig kEditorStyles = NovidentStylesConfig(
  defaultStyle: kDefaultBaseStyle,
  registry: NovidentStyleRegistry({
    ...kDefaultStyleRegistry.styles,
  }),
  defaultStylesByType: <String, NovidentStyleDefinition>{
    'table': kDefaultTableStyle,
  },
);

final NovidentStyleDefinition kDefaultBaseStyle = NovidentStyleDefinition(
  id: '__novident_base__',
  name: 'Base',
  fontSize: 12.0,
  fontFamily: getDefaultFont(),
  textColor: Colors.black,
  spacing: NovidentStyleSpacing(lineHeight: 1.0),
  indent: NovidentStyleIndent.defaultLineFilter(),
);
