import 'dart:convert';

import 'package:example/common/constants/contents/recipe_content.dart';
import 'package:example/common/constants/contents/text_formatting_content.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:novident_editor/novident_editor.dart' show Document;
import 'package:novident_nodes/novident_nodes.dart';

import 'contents/readme_document.dart';

String _content(Document document) => jsonEncode(document.toJson());

/// A fresh default workspace: project structure + initial document
/// contents, built together so the node ids match the content map.
///
/// Every call builds NEW node instances — tests boot several workspaces
/// without disposing shared mutable node state.
///
/// The workspace is a capability showcase: each document demonstrates a
/// group of editor features with realistic content. The README must stay at
/// root path `[0, 0]` — the desktop and mobile views select it on startup
/// through `root.atPath([0, 0])`.
({List<Node> nodes, Map<String, String> contents}) buildDefaultWorkspace() {
  final readme = File(
    details: NodeDetails.withLevel(1),
    name: 'README',
    createAt: DateTime.now(),
  );
  final textFormatting = File(
    details: NodeDetails.withLevel(1),
    name: 'Text & Formatting',
    createAt: DateTime.now(),
  );
  final recipe = File(
    details: NodeDetails.withLevel(1),
    name: 'Homemade Sourdough Bread',
    createAt: DateTime.now(),
  );

  // Keep this file structure-only: every document's content lives in its
  // own file under `constants/contents/` and is delivered through the
  // contents map below — the nodes themselves carry no content.
  //
  // Note: `README` must stay at root path `[0, 0]` — the desktop and
  // mobile views select it on startup through `root.atPath([0, 0])`.
  final nodes = <Node>[
    Directory(
      details: NodeDetails.zero(),
      name: 'Novident Showcase',
      createAt: DateTime.now(),
      isExpanded: true,
      children: [
        readme,
        textFormatting,
        recipe,
      ],
    ),
  ];

  final contents = <String, String>{
    readme.id: _content(readmeDocument),
    textFormatting.id: _content(textFormattingDocument),
    recipe.id: _content(recipeDocument),
  };

  return (nodes: nodes, contents: contents);
}
