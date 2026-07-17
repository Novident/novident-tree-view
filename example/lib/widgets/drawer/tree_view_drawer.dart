import 'package:example/common/configurations/tree_configs/tree_configurations.dart';
import 'package:example/common/controller/tree_controller.dart';
import 'package:example/widgets/drawer/drawer_header.dart';
import 'package:example/widgets/drawer/tree_view_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

/// Scrivener-like binder colors.
const Color _kBinderBackground = Color(0xFFF0EFEE);
const Color _kBinderBorder = Color(0xFFD6D6D6);

/// The binder: project header + toolbar + scrollable tree.
///
/// Kept as a [Drawer] so `android_view.dart` can keep using it inside
/// `Scaffold.drawer`; on desktop the parent `SizedBox` constrains its
/// width, so the default drawer width never applies there.
class TreeViewDrawer extends HookWidget {
  final TreeController controller;
  const TreeViewDrawer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    return SafeArea(
      top: true,
      child: Drawer(
        elevation: 0,
        backgroundColor: _kBinderBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: _kBinderBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const TreeViewHeaderTitle(),
              TreeViewToolbar(controller: controller),
              const Divider(height: 1, thickness: 1, color: _kBinderBorder),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  child: TreeView(
                    root: controller.root,
                    configuration: treeConfigurationBuilder(
                      controller,
                      context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
