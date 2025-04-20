import 'dart:convert';

import 'package:example/common/controller/tree_controller.dart';
import 'package:example/extensions/node_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Node;
import 'package:flutter_quill/quill_delta.dart';
import 'package:novident_nodes/novident_nodes.dart';

import '../../common/nodes/file.dart';
import '../drawer/tree_view_drawer.dart';
import '../editor/my_editor.dart';

class DesktopTreeViewExample extends StatefulWidget {
  final TreeController controller;
  const DesktopTreeViewExample({
    super.key,
    required this.controller,
  });

  @override
  State<DesktopTreeViewExample> createState() => _DesktopTreeViewExampleState();
}

class _DesktopTreeViewExampleState extends State<DesktopTreeViewExample> {
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late TreeController treeController;
  final ValueNotifier<bool> _isDraggingAboveEditor = ValueNotifier<bool>(false);
  bool _showNoFileToWatch = false;
  File? _lastNode;
  bool _onChangeCalledFromSelectionHandler = false;
  Delta oldVersion = Delta();

  @override
  void initState() {
    treeController = widget.controller..selectLastNode();
    _lastNode = treeController.selection.value! as File;
    _loadContent();
    super.initState();
  }

  @override
  void dispose() {
    treeController
      ..invalidateSelection()
      ..dispose();
    _isDraggingAboveEditor.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadContent() {
    var content = (_lastNode as File).content;
    if (content.isEmpty) content = '[{"insert":"\\n"}]';
    final delta = Delta.fromJson(
      jsonDecode(content),
    );
    oldVersion = delta;
    _controller.document = Document.fromDelta(delta);
    _onChangeCalledFromSelectionHandler = false;
  }

  void _onRemoveCurrentSelection() {
    _lastNode = null;
    _showNoFileToWatch = true;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  void _handleOnChangeSelection(Node? node) {
    if (_lastNode?.details == node?.details) return;
    if (node != null && node is! File) {
      _showNoFileToWatch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      _onChangeCalledFromSelectionHandler = true;
      return;
    }
    _lastNode = node as File?;
    _onChangeCalledFromSelectionHandler = true;
    if (_lastNode != null) {
      _loadContent();
      if (_showNoFileToWatch) {
        _showNoFileToWatch = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    }
  }

  bool onWillAcceptWithDetails(DragTargetDetails<Node> details) {
    _isDraggingAboveEditor.value = true;
    return details.data is File;
  }

  void onMove() {
    _isDraggingAboveEditor.value = true;
  }

  void onLeave() {
    _isDraggingAboveEditor.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_lastNode?.name ?? 'No name'),
      ),
      body: ValueListenableBuilder<Node?>(
        valueListenable: widget.controller.selection,
        builder: (BuildContext context, Node? value, Widget? __) {
          if (value == null) {
            _onRemoveCurrentSelection();
          } else {
            _handleOnChangeSelection(value);
          }
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.30,
                      height: size.height * 0.95,
                      child: TreeViewDrawer(controller: widget.controller),
                    ),
                    if (_showNoFileToWatch)
                      SizedBox(
                        width: size.width * 0.70,
                        height: size.height * 0.90,
                        child: const Center(
                          child: Text(
                            'There\'s no File to watch...',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    if (!_showNoFileToWatch)
                      Container(
                        width: size.width * 0.70,
                        height: size.height * 0.90,
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 17, bottom: 5),
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.hardEdge,
                          children: [
                            QuillSimpleToolbar(
                              controller: _controller,
                              config: const QuillSimpleToolbarConfig(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20,
                                  right: 10,
                                  top: size.height * 0.17,
                                  bottom: 10),
                              child: MyEditor(
                                controller: _controller,
                                scrollController: _scrollController,
                                configurations: const QuillEditorConfig(
                                  placeholder: 'Write something',
                                  scrollable: true,
                                  expands: true,
                                ),
                                focusNode: _focusNode,
                                onChange: (Document document) {
                                  if (_lastNode == null) return;
                                  if (!_onChangeCalledFromSelectionHandler) {
                                    final Delta currentDelta =
                                        document.toDelta();
                                    // making this check, we avoid make a update when it does not
                                    // needed. OnChange also is called when the selection changes
                                    if (oldVersion != currentDelta) {
                                      oldVersion = currentDelta;
                                      _lastNode!.owner?.asContainer.update(
                                        _lastNode!.copyWith(
                                          details: _lastNode!.details,
                                          content: jsonEncode(
                                            document.toDelta().toJson(),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: _isDraggingAboveEditor,
                              builder: (BuildContext context, bool isDragging,
                                  Widget? _) {
                                return Container(
                                  color: isDragging
                                      ? Colors.grey.withAlpha(140)
                                      : null,
                                  width: size.height,
                                  height: size.height,
                                  child: DragTarget<Node>(
                                    onMove: (_) => onMove(),
                                    onLeave: (_) => onLeave(),
                                    onWillAcceptWithDetails:
                                        onWillAcceptWithDetails,
                                    onAcceptWithDetails:
                                        (DragTargetDetails<Node> details) {
                                      _isDraggingAboveEditor.value = false;
                                      widget.controller
                                          .selectNode(details.data);
                                    },
                                    builder: (
                                      BuildContext context,
                                      List<Node?> candidateData,
                                      List<dynamic> rejectedData,
                                    ) {
                                      return Container(
                                        padding: EdgeInsets.only(
                                          left: size.width / 4,
                                          right: 10,
                                          top: size.height / 2.5,
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          'Select this node',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
