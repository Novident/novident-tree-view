import 'package:flutter_quill/quill_delta.dart';

/// Content for `Manuscript ▸ Chapter 1 ▸ Awakening`.
final Delta awakeningDelta = Delta()
  ..insert('Awakening')
  ..insert('\n', {'header': 2})
  ..insert('\n')
  ..insert('The first thing Elara noticed was the silence. Not the '
      'comfortable hush of a sleeping house, but a silence so complete '
      'it felt like a held breath.')
  ..insert('\n\n')
  ..insert('She sat up. The candle by her bed had burned down to a stub '
      'of wax, and the window she was certain she had latched the night '
      'before now stood open, its curtains perfectly still despite the '
      'cold air pouring in.')
  ..insert('\n\n')
  ..insert('Something is wrong with the woods tonight.', {'italic': true})
  ..insert('\n\n')
  ..insert('The thought arrived unbidden, the way her grandmother\'s '
      'warnings always did — half memory, half instinct. Beyond the '
      'garden wall, the treeline of the ')
  ..insert('Hollow Forest', {'bold': true})
  ..insert(' stood darker than the sky behind it, and no owl called, '
      'no branch creaked.')
  ..insert('\n\n')
  ..insert('Her grandmother used to say:')
  ..insert('\n')
  ..insert('When the forest goes quiet, it is because it is listening.')
  ..insert('\n', {'blockquote': true})
  ..insert('\n')
  ..insert('Elara pulled on her boots, took the iron knife from the '
      'drawer, and did the one thing every sensible person in the '
      'village would have told her not to do.')
  ..insert('\n\n')
  ..insert('She went outside.')
  ..insert('\n');
