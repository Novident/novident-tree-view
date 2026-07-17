import 'package:flutter_quill/quill_delta.dart';

/// Content for `Manuscript ▸ Chapter 2 ▸ The Tavern`.
final Delta tavernDelta = Delta()
  ..insert('The Tavern')
  ..insert('\n', {'header': 2})
  ..insert('\n')
  ..insert('The ')
  ..insert('Wandering Lantern', {'bold': true})
  ..insert(' was the only building in the village with its windows '
      'still lit past midnight, and the only place where questions '
      'about the forest were answered with anything other than a '
      'closed door.')
  ..insert('\n\n')
  ..insert('Elara pushed inside. The warmth hit her first — woodsmoke, '
      'spilled ale, wet wool. A dozen faces turned toward her, then '
      'quickly away. Only the innkeeper held her gaze.')
  ..insert('\n\n')
  ..insert('"You\'ve seen it," he said. Not a question.')
  ..insert('\n\n')
  ..insert('He set down the mug he had been drying and nodded toward '
      'the empty stool at the end of the bar, the one nobody ever '
      'seemed to sit on.')
  ..insert('\n\n')
  ..insert('"Twelve stones," she said quietly.')
  ..insert('\n\n')
  ..insert('The room went still. Someone\'s chair scraped. The fire '
      'popped once, loud as a snapped branch.')
  ..insert('\n\n')
  ..insert('"Then it\'s chosen the path," the innkeeper said. "And '
      'paths, girl — paths go both ways."')
  ..insert('\n', {'blockquote': true})
  ..insert('\n');
