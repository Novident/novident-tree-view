import 'package:flutter_quill/quill_delta.dart';

final Delta exampleDelta = Delta()
  ..insert('🌳 Novident Tree View')
  ..insert('\n', {"header": 1})
  ..insert('\n')
  ..insert(
      'This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through ')
  ..insert('Listenable', {"code": true})
  ..insert(' patterns, enabling reactive updates without complex state management.')
  ..insert('\n\n')
  ..insert('💡 Motivation')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert(
      'We\'ve investigated several alternatives that allow for convenient node tree creation with a standards-compliant implementation. \n\nHowever, we couldn\'t find one. Most of these implementations required initializing a controller or similar to allow for a proper flow of actions within the tree.\n\nHowever, for ')
  ..insert('Novident', {"bold": true})
  ..insert(
      ', this isn\'t what we\'re looking for. Our goal is to create a common solution that allows us to:\n\n')
  ..insert('Listen for changes to Nodes manually')
  ..insert('\n', {"list": "ul"})
  ..insert('Send or force updates to specific Nodes')
  ..insert('\n', {"list": "ul"})
  ..insert('Have a common operation flow (insert, '
      'delete, move, or update) for nodes within the tree that depends '
      'on the user\'s implementation and not '
      'the package (complete control over them)')
  ..insert('\n', {"list": "ul"})
  ..insert('Better support for Node configuration')
  ..insert('\n', {"list": "ul"})
  ..insert('\nThis is why we decided to create this package, which adds everything ')
  ..insert('Novident', {"bold": true})
  ..insert(
    ' requires in one place. \n\nIn this package, we can simply add a few '
    'configurations and leave everything '
    'else to it, as our own logic can create a beautiful file/node tree '
    'without too much code or the need for drivers.',
  )
  ..insert('\n\n')
  ..insert('📦 Installation')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert('Add to your ')
  ..insert('pubspec.yaml', {"code": true})
  ..insert(':\n\n')
  ..insert('dependencies:')
  ..insert('\n', {'code-block': true})
  ..insert('  novident_tree_view: <latest_version>')
  ..insert('\n', {'code-block': true})
  ..insert('  novident_nodes: <lastest_version>')
  ..insert('\n', {"code-block": true})
  ..insert('\n')
  ..insert('🔎 Resources')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert('Since there\'s a lot to explain and implement, we prefer '
      'to provide a separate document for each section to explain more concretely and '
      'accurately what each point entails.\n\n')
  ..insert('✍️ Nodes Gestures', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes_gestures.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('📲 Components', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/components.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('🌱 Nodes', {
    'link': 'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('🌲 Tree Configuration', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/tree_configuration.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('📜 Drag and Drop details', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/drag_and_drop_details.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('🤏 Draggable Configurations', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/draggable_configurations.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('📏 Indentation Configuration', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/indentation_configuration.md',
  })
  ..insert('\n', {"list": "ul"})
  ..insert('\n')
  ..insert('📝 Recipes')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert('🗃️ Tree Files', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/'
  })
  ..insert('\n', {'list': 'ul'})
  ..insert('\n')
  ..insert('More recipes will be added later', {"italic": true})
  ..insert('\n\n')
  ..insert('🌳 Contributing', {"header": 2})
  ..insert('\n')
  ..insert('\n')
  ..insert(
      'We greatly appreciate your time and effort.\n\nTo keep the project consistent '
      'and maintainable, we have a few guidelines that we ask all contributors to follow. These '
      'guidelines help ensure that everyone can understand '
      'and work with the code easier.\n\nSee ')
  ..insert('Contributing', {
    "link": "https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md"
  })
  ..insert(' for more details.')
  ..insert('\n');
