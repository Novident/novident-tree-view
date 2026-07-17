import 'package:flutter_quill/quill_delta.dart';

/// Content for `Places ▸ The Hollow Forest` (setting sheet).
final Delta placeHollowForestDelta = Delta()
  ..insert('The Hollow Forest')
  ..insert('\n', {'header': 2})
  ..insert('\n')
  ..insert('Ancient woodland bordering Bryrmoor to the north. The '
      'canopy is dense enough that noon looks like dusk, and the '
      'village marks its only safe path with white granite stones.')
  ..insert('\n\n')
  ..insert('Rules of the forest')
  ..insert('\n', {'header': 3})
  ..insert('\n')
  ..insert('The stones count themselves. If the count changes, the '
      'path has changed.')
  ..insert('\n', {'list': 'ordered'})
  ..insert('Silence means it is listening. Noise means it is speaking.')
  ..insert('\n', {'list': 'ordered'})
  ..insert('Never follow the lantern light.')
  ..insert('\n', {'list': 'ordered'})
  ..insert('\n')
  ..insert('Open questions')
  ..insert('\n', {'header': 3})
  ..insert('\n')
  ..insert('Who set the original eleven stones?')
  ..insert('\n', {'list': 'bullet'})
  ..insert('Why does the forest never cross the garden walls?')
  ..insert('\n', {'list': 'bullet'})
  ..insert('What did it take from the innkeeper?')
  ..insert('\n', {'list': 'bullet'})
  ..insert('\n');
