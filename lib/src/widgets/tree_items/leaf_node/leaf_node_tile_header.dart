import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

class LeafNodeTileHeader extends StatelessWidget {
  final LeafNode leafNode;
  final TreeConfiguration configuration;
  final double extraLeftIndent;
  const LeafNodeTileHeader({
    required this.leafNode,
    required this.configuration,
    required this.extraLeftIndent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool existExpandableButton =
        configuration.containerConfiguration.showDefaultExpandableButton ||
            configuration.containerConfiguration.expandableIconConfiguration
                    ?.customExpandableWidget !=
                null;
    double indent = configuration.customComputeNodeIndentByLevel?.call(
          leafNode,
        ) ??
        defaultComputePadding(existExpandableButton)!;
    indent = indent + extraLeftIndent;
    final Widget? trailing =
        configuration.leafConfiguration.trailing?.call(leafNode, context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: configuration.leafConfiguration.leading(leafNode, context),
        ),
        configuration.leafConfiguration.content(leafNode, context),
        if (trailing != null) trailing,
      ],
    );
  }

  double? defaultComputePadding(bool existExpandableButton) {
    return configuration.customComputeNodeIndentByLevel != null
        ? configuration.customComputeNodeIndentByLevel?.call(leafNode)
        : existExpandableButton
            ? computePaddingForLeaf(leafNode.level)
            : computePaddingForLeafWithoutExpandable(leafNode.level)!;
  }
}
