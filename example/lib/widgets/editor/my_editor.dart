import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MyEditor extends HookWidget {
  final QuillController _controller;

  final void Function(Document document) onChange;
  final ScrollController _scrollController;
  final FocusNode _focusNode;
  final QuillEditorConfig configurations;
  const MyEditor({
    super.key,
    required QuillController controller,
    required ScrollController scrollController,
    required FocusNode focusNode,
    required this.onChange,
    required this.configurations,
  })  : _controller = controller,
        _scrollController = scrollController,
        _focusNode = focusNode;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _controller.addListener(_onChangeUpdate);
      return () => _controller.removeListener(_onChangeUpdate);
    }, [_controller.document]);
    return QuillEditor(
      controller: _controller,
      scrollController: _scrollController,
      focusNode: _focusNode,
      config: configurations,
    );
  }

  void _onChangeUpdate() {
    onChange.call(_controller.document);
  }
}
