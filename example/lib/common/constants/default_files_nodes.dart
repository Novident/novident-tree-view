import 'dart:convert';

import 'package:example/common/constants/contents/chapter_one_awakening_content.dart';
import 'package:example/common/constants/contents/chapter_one_dark_woods_content.dart';
import 'package:example/common/constants/contents/chapter_two_tavern_content.dart';
import 'package:example/common/constants/contents/character_elara_content.dart';
import 'package:example/common/constants/contents/place_hollow_forest_content.dart';
import 'package:example/common/constants/example_delta_content.dart';
import 'package:example/common/nodes/directory.dart';
import 'package:example/common/nodes/file.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:novident_nodes/novident_nodes.dart';

String _content(Delta delta) => jsonEncode(delta.toJson());

/// Scrivener-like default project structure.
///
/// Keep this file structure-only: every document's content lives in its
/// own file under `constants/contents/` (same pattern as
/// [exampleDelta] in `example_delta_content.dart`).
///
/// Note: `Research` must stay at root index `1` — the desktop view
/// selects the README on startup through `root.atPath([1, 0])`.
final List<Node> defaultNodes = <Node>[
  Directory(
    details: NodeDetails.zero(),
    name: 'Manuscript',
    createAt: DateTime.now(),
    children: [
      Directory(
        details: NodeDetails(level: 1),
        name: 'Chapter 1',
        createAt: DateTime.now(),
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'Awakening',
            content: _content(awakeningDelta),
            createAt: DateTime.now(),
          ),
          File(
            details: NodeDetails.withLevel(2),
            name: 'Dark Woods',
            content: _content(darkWoodsDelta),
            createAt: DateTime.now(),
          ),
        ],
      ),
      Directory(
        details: NodeDetails(level: 1),
        name: 'Chapter 2',
        createAt: DateTime.now(),
        children: [
          File(
            details: NodeDetails.withLevel(2),
            name: 'The Tavern',
            content: _content(tavernDelta),
            createAt: DateTime.now(),
          ),
        ],
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Research',
    createAt: DateTime.now(),
    children: [
      File(
        details: NodeDetails.withLevel(1),
        name: 'README',
        content: _content(exampleDelta),
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Characters',
    createAt: DateTime.now(),
    children: [
      File(
        details: NodeDetails.withLevel(1),
        name: 'Elara',
        content: _content(characterElaraDelta),
        createAt: DateTime.now(),
      ),
    ],
  ),
  Directory(
    details: NodeDetails.withLevel(0),
    name: 'Places',
    createAt: DateTime.now(),
    children: [
      File(
        details: NodeDetails.withLevel(1),
        name: 'The Hollow Forest',
        content: _content(placeHollowForestDelta),
        createAt: DateTime.now(),
      ),
    ],
  ),
];
