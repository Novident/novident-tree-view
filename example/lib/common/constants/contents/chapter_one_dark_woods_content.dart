import 'package:flutter_quill/quill_delta.dart';

/// Content for `Manuscript ▸ Chapter 1 ▸ Dark Woods`.
final Delta darkWoodsDelta = Delta()
  ..insert('Dark Woods')
  ..insert('\n', {'header': 2})
  ..insert('\n')
  ..insert('The path into the Hollow Forest had never frightened her in '
      'daylight. She had walked it a hundred times, basket in hand, '
      'counting the white stones her father had set along its edge.')
  ..insert('\n\n')
  ..insert('Tonight she counted them again.')
  ..insert('\n\n')
  ..insert('Twelve. There had always been eleven.', {'italic': true})
  ..insert('\n\n')
  ..insert('She stopped beside the new stone. It was the same pale '
      'granite as the others, worn smooth as if it had sat there for '
      'decades, moss climbing its northern face. But it had ')
  ..insert('not', {'bold': true})
  ..insert(' been there yesterday.')
  ..insert('\n\n')
  ..insert('Somewhere deeper between the trees, a light flickered — '
      'warm and orange, like a lantern swinging from someone\'s hand. '
      'It was moving away from her, unhurried, patient.')
  ..insert('\n\n')
  ..insert('Every story she had ever been told ended the same way: ')
  ..insert('never follow the lantern', {'italic': true})
  ..insert('.')
  ..insert('\n\n')
  ..insert('But the stories never mentioned what the lantern does when '
      'you refuse. It stops. And then it starts moving toward ')
  ..insert('you', {'bold': true})
  ..insert('.')
  ..insert('\n');
