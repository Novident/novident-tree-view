import 'package:novident_editor/novident_editor.dart';

final Document readmeDocument = Document(
  root: pageNode(
    children: <Node>[
      // Heading 1: 🌳 Novident Tree View
      headingNode(
        level: 1,
        delta: Delta()..insert('🌳 Novident Tree View'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert(
              'This package provides a flexible solution for displaying hierarchical data structures while giving developers full control over node management. Unlike traditional tree implementations that enforce controller-based architectures, this package operates on simple data types that you extend to create your node hierarchy. Nodes become self-aware of their state changes through ')
          ..insert('Listenable', attributes: {'code': true})
          ..insert(
              ' patterns, enabling reactive updates without complex state management.'),
      ),
      headingNode(
        level: 2,
        delta: Delta()..insert('💡 Motivation'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert(
              'We\'ve investigated several alternatives that allow for convenient node tree creation with a standards-compliant implementation. But, we couldn\'t find one that satisfies our requirements. Most of these implementations required initializing a controller or similar to allow for a proper flow of actions within the tree. However, for ')
          ..insert('Novident', attributes: {'bold': true})
          ..insert(
              ', this isn\'t what we\'re looking for. Our goal is to create a common solution that allows us to:'),
      ),
      bulletedListNode(
        delta: Delta()..insert('Listen for changes to Nodes manually'),
      ),
      bulletedListNode(
        delta: Delta()..insert('Send or force updates to specific Nodes'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert(
              'Have a common operation flow (insert, delete, move, or update) for nodes within the tree that depends on the user\'s implementation and not the package (complete control over them)'),
      ),
      bulletedListNode(
        delta: Delta()..insert('Better support for Node configuration'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert(
              'This is why we decided to create this package, which adds everything ')
          ..insert('Novident', attributes: {'bold': true})
          ..insert(
              ' requires in one place. In this package, we can simply add a few configurations and leave everything else to it, as our own logic can create a beautiful file/node tree without too much code or the need for drivers.'),
      ),
      headingNode(
        level: 2,
        delta: Delta()..insert('📦 Installation'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert('Add to your ')
          ..insert('pubspec.yaml', attributes: {'code': true})
          ..insert(':'),
      ),
      paragraphNode(
        delta: Delta()..insert('dependencies:'),
      ),
      paragraphNode(
        delta: Delta()..insert('  novident_tree_view: <latest_version>'),
      ),
      paragraphNode(
        delta: Delta()..insert('  novident_nodes: <latest_version>'),
      ),
      headingNode(
        level: 2,
        delta: Delta()..insert('🔎 Resources'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert(
              'Since there\'s a lot to explain and implement, we prefer to provide a separate document for each section to explain more concretely and accurately what each point entails.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('🌱 Nodes', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('Node', attributes: {'code': true})
          ..insert(' is and where it comes from, as well as a special mixin: ')
          ..insert('DragAndDropMixin', attributes: {'code': true})
          ..insert(
              ' that is necessary for nodes to be able to use the Drag and Drop feature.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('📲 Components', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/components.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('NodeComponentBuilder', attributes: {'code': true})
          ..insert(
              ' (which is responsible for rendering nodes) is, and how you can create your own versions so you can create your own implementations of each Node.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('🌲 Tree Configuration', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/tree_configuration.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('TreeConfiguration', attributes: {'code': true})
          ..insert(
              ' is and all the properties that allow this package to render and use your Nodes to show a more effective appearance that simulates a node tree.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('🤏 Draggable Configurations', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/draggable_configurations.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('DraggableConfiguration', attributes: {'code': true})
          ..insert(
              ' is, and how you can use it to configure the visual appearance of your nodes during Drag and Drop events.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('📏 Indentation Configuration', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/indentation_configuration.md'
          })
          ..insert(': In this section, we explain what an ')
          ..insert('IndentConfiguration', attributes: {'code': true})
          ..insert(
              ' is, and how you can use it to add indentation to your nodes in a simple yet effective way.'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('📜 Drag and Drop details', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/drag_and_drop_details.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('NovDragAndDropDetails', attributes: {'code': true})
          ..insert(
              ' is, and what it is typically used for (and even how it is used internally to calculate certain positions during drag and drop events).'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('✍️ Nodes Gestures', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/nodes_gestures.md'
          })
          ..insert(': In this section, we explain what a ')
          ..insert('NodeDragGestures', attributes: {'code': true})
          ..insert(' is and how you can configure it quickly and easily.'),
      ),
      headingNode(
        level: 2,
        delta: Delta()..insert('📝 Recipes'),
      ),
      bulletedListNode(
        delta: Delta()
          ..insert('🗃️ Tree Files', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/doc/recipes/tree_file/tree_file.md'
          })
          ..insert(
              ': We designed an example of how you could recreate a file tree using this package quickly and easily, without too much code, but that allows you to simulate the standard behaviors of a file tree.'),
      ),
      paragraphNode(
        delta: Delta()
          ..insert('More recipes will be added later',
              attributes: {'italic': true}),
      ),
      headingNode(
        level: 2,
        delta: Delta()..insert('🌳 Contributing'),
      ),
      // Paragraph
      paragraphNode(
        delta: Delta()
          ..insert(
              'We greatly appreciate your time and effort. To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier. See ')
          ..insert('Contributing', attributes: {
            'href':
                'https://github.com/Novident/novident-tree-view/blob/master/CONTRIBUTING.md'
          })
          ..insert(' for more details.'),
      ),
    ],
  ),
);
