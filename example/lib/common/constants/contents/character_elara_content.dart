import 'package:flutter_quill/quill_delta.dart';

/// Content for `Characters ▸ Elara` (character sheet).
final Delta characterElaraDelta = Delta()
  ..insert('Elara')
  ..insert('\n', {'header': 2})
  ..insert('\n')
  ..insert('Role: ', {'bold': true})
  ..insert('Protagonist')
  ..insert('\n', {'list': 'bullet'})
  ..insert('Age: ', {'bold': true})
  ..insert('19')
  ..insert('\n', {'list': 'bullet'})
  ..insert('Home: ', {'bold': true})
  ..insert('Bryrmoor, last village before the Hollow Forest')
  ..insert('\n', {'list': 'bullet'})
  ..insert('Keepsake: ', {'bold': true})
  ..insert('Her grandmother\'s iron knife')
  ..insert('\n', {'list': 'bullet'})
  ..insert('\n')
  ..insert('Overview')
  ..insert('\n', {'header': 3})
  ..insert('\n')
  ..insert('Raised by her grandmother after the forest "kept" her '
      'parents, Elara grew up on the warnings everyone else treats as '
      'superstition. She is practical, stubborn, and quietly convinced '
      'that the stories are instructions, not entertainment.')
  ..insert('\n\n')
  ..insert('Voice notes')
  ..insert('\n', {'header': 3})
  ..insert('\n')
  ..insert(
      'Short sentences under pressure. Counts things when she is '
      'afraid — stones, steps, breaths.',
      {'italic': true})
  ..insert('\n');
