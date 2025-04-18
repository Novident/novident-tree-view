import 'package:flutter_quill/quill_delta.dart';

final Delta exampleDelta = Delta()
  ..insert('This is an example about how works ')
  ..insert('Flutter Tree View', {"code": true})
  ..insert('\n', {"header": 1})
  ..insert('This package allow us create complex tree\'s using ')
  ..insert('TreeNode', {"code": true, "bold": true})
  ..insert(' class')
  ..insert('\n');
