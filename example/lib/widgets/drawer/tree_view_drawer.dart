import 'package:example/common/controller/tree_controller.dart';
import 'package:example/common/default_configurations/configurations.dart';
import 'package:example/widgets/drawer/drawer_header.dart';
import 'package:example/widgets/drawer/tree_view_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:novident_tree_view/novident_tree_view.dart';

class TreeViewDrawer extends HookWidget {
  final TreeController controller;
  const TreeViewDrawer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final scrollController = useScrollController();
    return SafeArea(
      top: true,
      child: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero)),
        width: size.width * 0.95,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
                right:
                    BorderSide(color: Colors.black.withOpacity(0.4), width: 1)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TreeViewHeaderTitle(),
                TreeViewToolbar(controller: controller),
                TreeView(
                  root: controller.root,
                  configuration: treeConfigurationBuilder(controller, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
