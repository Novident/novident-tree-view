import 'package:example/common/default_nodes_demo.dart';
import 'package:example/common/entities/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';
import 'common/entities/directory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TreeController _controller = TreeController('root', defaultNodes);

  @override
  void dispose() {
    context.disposeTree();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: TreeProvider(
        controller: _controller,
        child: const MyHomePage(
          title: 'Flutter Tree View Demo',
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showExpandableButton = true;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              showExpandableButton = !showExpandableButton;
              setState(() {});
            },
            icon: const Icon(
              Icons.check,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TreeView(
              configuration: TreeConfiguration(
                activateDragAndDropFeature: true,
                buildFeedback: (node) {
                  return Material(
                    surfaceTintColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(node is File ? node.name : (node as Directory).name),
                    ),
                  );
                },
                buildSectionBetweenNodes: (node, object) {
                  return Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
                leafConfiguration: LeafConfiguration(
                  leafBoxDecoration: (leaf, isSelected, isDraggingAboveThisNode) => BoxDecoration(
                    color: isSelected ? Colors.black.withOpacity(0.10) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: size.height * 0.070,
                  leading: (leaf, indent, context) => Padding(
                    padding: EdgeInsets.only(left: indent, right: 5),
                    child: const Icon(CupertinoIcons.doc_text),
                  ),
                  content: (LeafTreeNode leaf, indent, context) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          '${(leaf as File).name} - ${leaf.level}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                  trailing: (LeafTreeNode node, indent, context) {
                    return IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () async {
                        final position = render_position(context);
                        await showMenu(context: context, position: position, items: [
                          PopupMenuItem(
                            onTap: () {
                              context.readTree().removeAt(node.id);
                            },
                            child: const Text('Delete'),
                          ),
                        ]);
                      },
                    );
                  },
                ),
                overrideDefaultActions: false,
                compositeConfiguration: CompositeConfiguration(
                  showExpandableButton: showExpandableButton,
                  expandableIconConfiguration: const ExpandableIconConfiguration(),
                  compositeBoxDecoration: (compositeNode, isSelected, isDraggingAboveThisNode) => BoxDecoration(
                    color: isSelected ? Colors.black.withOpacity(0.10) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
                  height: size.height * 0.070,
                  leading: (CompositeTreeNode node, indent, context) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                        node.isExpanded && node.isEmpty ? CupertinoIcons.folder_open : CupertinoIcons.folder_fill),
                  ),
                  content: (CompositeTreeNode node, indent, context) => Expanded(
                    child: Text(
                      '${(node as Directory).name} - ${node.level}',
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: (node, indent, context) {
                    return IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () async {
                        final position = render_position(context);
                        await showMenu(context: context, position: position, items: [
                          PopupMenuItem(
                            onTap: () {
                              context.readTree().insertAt(
                                  File(
                                    node: Node.withId(),
                                    nodeParent: node.id,
                                    name: 'File',
                                    createAt: DateTime.now(),
                                  ),
                                  node.id,
                                  removeIfNeeded: true);
                              return;
                            },
                            child: const Text('Add a document'),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              context.readTree().insertAt(
                                  Directory(
                                    node: Node.withId(),
                                    children: List.from([]),
                                    isExpanded: false,
                                    nodeParent: node.id,
                                    name: 'Directory',
                                    createAt: DateTime.now(),
                                  ),
                                  node.id,
                                  removeIfNeeded: true);
                            },
                            child: const Text('Add a directory'),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              context.readTree().removeAt(node.id);
                            },
                            child: const Text('Delete this directory'),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              context.readTree().clearChildrenByNode(node.id);
                            },
                            child: const Text('Clear'),
                          ),
                        ]);
                      },
                    );
                  },
                  onDraggedNodeIsAbove: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  RelativeRect render_position(BuildContext context, [Size? size]) {
    size ??= MediaQuery.sizeOf(context);
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, -65), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + const Offset(-50, 0), ancestor: overlay),
      ),
      Offset.zero & size * 0.40,
    );
    return position;
  }
}
