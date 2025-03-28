import 'dart:convert';

import 'package:example/common/controller/tree_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Node;
import 'package:flutter_quill/quill_delta.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

import '../../common/entities/file.dart';
import '../drawer/tree_view_drawer.dart';
import '../editor/my_editor.dart';

class AndroidTreeViewExample extends StatefulWidget {
  final TreeController controller;
  const AndroidTreeViewExample({
    super.key,
    required this.controller,
  });

  @override
  State<AndroidTreeViewExample> createState() => _AndroidTreeViewExampleState();
}

class _AndroidTreeViewExampleState extends State<AndroidTreeViewExample> {
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final TreeController? treeController;
  bool _isFirst = true;
  bool _showNoFileToWatch = false;
  File? _lastNode;

  @override
  void initState() {
    treeController = widget.controller;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadContent() {
    var content = (_lastNode as File).content;
    if (content.isEmpty) content = '[{"insert":"\\n"}]';
    _controller.document = Document.fromDelta(
      Delta.fromJson(
        jsonDecode(content),
      ),
    );
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

  void _handleFirstLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Find the last node to show an example of how works this feature
      if (_isFirst) {
        _isFirst = false;
        _lastNode = treeController?.root.children.lastOrNull as File?;
        if (treeController != null) {
          widget.controller.selectNode(_lastNode);
          _loadContent();
        }
      }
    });
  }

  void _handleOnChangeSelection(Node? node) {
    if (_lastNode?.id == node?.id) return;
    _lastNode = node as File?;
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    _handleFirstLoad();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_lastNode?.name ?? 'No name'),
      ),
      drawer: TreeViewDrawer(
        controller: widget.controller,
      ),
      body: ValueListenableBuilder(
          valueListenable: widget.controller.selection,
          builder: (ctx, value, _) {
            if (value == null) {
              _onRemoveCurrentSelection();
            } else {
              _handleOnChangeSelection(value);
            }
            return _showNoFileToWatch
                ? SizedBox(
                    width: size.width * 0.90,
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
                  )
                : Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 13, right: 13, top: 10),
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
                                  treeController ??= widget.controller;
                                  final newNodeState = _lastNode!.copyWith(
                                    content:
                                        jsonEncode(document.toDelta().toJson()),
                                  );
                                  //TODO. change this part because, when we select a node with content, calls to update node
                                  final bool wasNotFounded =
                                      !treeController!.updateNodeAtWithCallback(
                                    newNodeState.id,
                                    (Node originalNode) {
                                      return newNodeState;
                                    },
                                  );
                                  if (wasNotFounded) {
                                    throw Exception(
                                      'The node ${newNodeState.name} not '
                                      'exist into the current Tree state',
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          QuillSimpleToolbar(
                            controller: _controller,
                            config: const QuillSimpleToolbarConfig(
                              multiRowsDisplay: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
          }),
    );
  }
}
