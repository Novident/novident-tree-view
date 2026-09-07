import 'package:novident_editor/novident_editor.dart';

/// Content for `Novident Showcase ▸ Text & Formatting`.
///
/// Demonstrates the six heading levels, inline text styles (bold, italic,
/// underline, strikethrough, code, links, colors) and named styles via
/// `styleRef`.
final Document textFormattingDocument = Document(
  root: pageNode(
    children: <Node>[
      headingNode(level: 1, text: 'Text & Formatting'),
      paragraphNode(
        text: 'This document shows how Novident renders text: six heading '
            'levels, inline styles, links, colors and named styles.',
      ),
      headingNode(level: 2, text: 'Headings'),
      paragraphNode(
        text: 'Headings are built with `headingNode(level: n, text: ...)`. '
            'The level goes from 1 (largest) to 6 (smallest).',
      ),
      headingNode(level: 1, text: 'Heading 1'),
      headingNode(level: 2, text: 'Heading 2'),
      headingNode(level: 3, text: 'Heading 3'),
      headingNode(level: 4, text: 'Heading 4'),
      headingNode(level: 5, text: 'Heading 5'),
      headingNode(level: 6, text: 'Heading 6'),
      headingNode(level: 2, text: 'Inline styles'),
      paragraphNode(
        delta: Delta()
          ..insert('Rich text is a Quill-style Delta. You can combine ')
          ..insert('bold',
              attributes: <String, dynamic>{RichTextKeys.bold: true})
          ..insert(', ')
          ..insert('italic',
              attributes: <String, dynamic>{RichTextKeys.italic: true})
          ..insert(', ')
          ..insert('underline',
              attributes: <String, dynamic>{RichTextKeys.underline: true})
          ..insert(' and ')
          ..insert('strikethrough',
              attributes: <String, dynamic>{RichTextKeys.strikethrough: true})
          ..insert(' in a single paragraph.'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert('Inline ')
          ..insert('code',
              attributes: <String, dynamic>{RichTextKeys.code: true})
          ..insert(' is rendered with a monospace font, and you can add a ')
          ..insert(
            'hyperlink',
            attributes: <String, dynamic>{
              RichTextKeys.href: 'https://github.com/Novident/novident-editor',
            },
          )
          ..insert(' that opens on tap.'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert('Text can be ')
          ..insert('colored',
              attributes: <String, dynamic>{RichTextKeys.textColor: '#FF5722'})
          ..insert(' and ')
          ..insert('highlighted', attributes: <String, dynamic>{
            RichTextKeys.backgroundColor: '#FFF59D'
          })
          ..insert(' with a background color.'),
      ),
      headingNode(level: 2, text: 'Named styles'),
      paragraphNode(
        text: 'A paragraph can reference a named style with `styleRef`. '
            'These two paragraphs reuse the built-in heading styles without '
            'being heading blocks:',
      ),
      paragraphNode(
        text: 'This paragraph uses the "Heading 1" named style.',
        styleRef: kHeadingDefaultStyles[0].id,
      ),
      paragraphNode(
        text: 'This one uses "Heading 3".',
        styleRef: kHeadingDefaultStyles[2].id,
      ),
      headingNode(level: 2, text: 'Text direction'),
      paragraphNode(
        text: 'Blocks support right-to-left text. This paragraph is '
            'rendered right-to-left:',
        textDirection: 'rtl',
      ),
      paragraphNode(
        delta: Delta()..insert('مرحباً بكم في محرر نوفيدنت'),
        textDirection: 'rtl',
      ),
    ],
  ),
);
