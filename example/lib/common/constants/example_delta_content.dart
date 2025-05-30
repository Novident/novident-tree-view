import 'package:flutter_quill/quill_delta.dart';

final Delta exampleDelta = Delta()
  ..insert('🌳 Novident Tree View')
  ..insert('\n', {"header": 1})
  ..insert('\n')
  ..insert(
      'This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through ')
  ..insert('Listenable', {"code": true})
  ..insert(
      ' patterns, enabling reactive updates without complex state management.')
  ..insert('\n\n')
  ..insert('💡 Motivation')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert(
      'We\'ve investigated several alternatives that allow for convenient node tree creation with a standards-compliant implementation. But, we couldn\'t find one that satisfies our requirements. Most of these implementations required initializing a controller or similar to allow for a proper flow of actions within the tree.\n\nHowever, for ')
  ..insert('Novident', {"bold": true})
  ..insert(
      ', this isn\'t what we\'re looking for. Our goal is to create a common solution that allows us to:\n\n')
  ..insert('Listen for changes to Nodes manually')
  ..insert('\n', {"list": "bullet"})
  ..insert('Send or force updates to specific Nodes')
  ..insert('\n', {"list": "bullet"})
  ..insert('Have a common operation flow (insert, '
      'delete, move, or update) for nodes within the tree that depends '
      'on the user\'s implementation and not '
      'the package (complete control over them)')
  ..insert('\n', {"list": "bullet"})
  ..insert('Better support for Node configuration')
  ..insert('\n', {"list": "bullet"})
  ..insert(
      '\nThis is why we decided to create this package, which adds everything ')
  ..insert('Novident', {"bold": true})
  ..insert(
    ' requires in one place. \n\nIn this package, we can simply add a few '
    'configurations and leave everything '
    'else to it, as our own logic can create a beautifbullet file/node tree '
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
  ..insert('🌱 Nodes', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md',
  })
  ..insert(': In this section, we explain what a ')
  ..insert('Node', {'code': true})
  ..insert(' is and where '
      'it comes from, as well as '
      'a special mixin: ')
  ..insert('DragAndDropMixin', {'code': true})
  ..insert(' that is necessary for '
      'nodes to be able '
      'to use the **Drag and Drop** feature.')
  ..insert('\n', {"list": "bullet"})
  ..insert('📲 Components', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/components.md',
  })
  ..insert(': In this section, we explain '
      'what a ')
  ..insert('NodeComponentBuilder', {'code': true})
  ..insert(' (which is responsible for '
      'rendering nodes) is, and how you can create your '
      'own versions so you can create your own implementations of each Node.')
  ..insert('\n', {"list": "bullet"})
  ..insert('🌲 Tree Configuration', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/tree_configuration.md',
  })
  ..insert(': In this section, we explain '
      'what a ')
  ..insert('TreeConfiguration', {'code': true})
  ..insert(' is and all the properties that allow this '
      'package to render and use your Nodes to show a more effective '
      'appearance that simulates a node tree.')
  ..insert('\n', {"list": "bullet"})
  ..insert('🤏 Draggable Configurations', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/draggable_configurations.md',
  })
  ..insert(': In this section, we explain what a ')
  ..insert('DraggableConfiguration', {'code': true})
  ..insert(' is, and how you can use it to configure '
      'the visual appearance of your nodes during Drag and Drop events.')
  ..insert('\n', {"list": "bullet"})
  ..insert('📏 Indentation Configuration', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/indentation_configuration.md',
  })
  ..insert(': In this section, we explain '
      'what an ')
  ..insert('IndentConfiguration', {'code': true})
  ..insert(' is, and how you can use '
      'it to add indentation to your nodes in a '
      'simple yet effective way.')
  ..insert('\n', {"list": "bullet"})
  ..insert('📜 Drag and Drop details', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/drag_and_drop_details.md',
  })
  ..insert(': In this section, we explain '
      'what a ')
  ..insert('NovDragAndDropDetails', {'code': true})
  ..insert(' is, and what it is '
      'typically used for (and even how it is used internally to '
      'calculate certain positions during drag and drop events).')
  ..insert('\n', {"list": "bullet"})
  ..insert('✍️ Nodes Gestures', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes_gestures.md',
  })
  ..insert(': In this section, we explain '
      'what a ')
  ..insert('NodeDragGestures', {'code': true})
  ..insert(' is and how you can configure it '
      'quickly and easily.')
  ..insert('\n', {"list": "bullet"})
  ..insert('\n')
  ..insert('📝 Recipes')
  ..insert('\n', {"header": 2})
  ..insert('\n')
  ..insert('🗃️ Tree Files', {
    'link':
        'https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/tree_file.md'
  })
  ..insert(': We designed an example of how you could recreate a '
      'file tree using this package quickly and easily, '
      'without too much code, but that allows you to '
      'simulate the standard behaviors of a file tree.')
  ..insert('\n', {'list': 'bullet'})
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
    "link":
        "https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md"
  })
  ..insert(' for more details.')
  ..insert('\n');
