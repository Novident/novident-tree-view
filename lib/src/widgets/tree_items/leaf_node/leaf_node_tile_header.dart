import 'package:flutter/material.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

class LeafNodeTileHeader extends StatelessWidget {
  final LeafNode singleNode;
  final TreeConfiguration configuration;
  final double extraLeftIndent;
  const LeafNodeTileHeader({
    required this.singleNode,
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
    double indent = (configuration.customComputeNodeIndentByLevel
            ?.call(singleNode) ??
        (configuration.customComputeNodeIndentByLevel != null
            ? configuration.customComputeNodeIndentByLevel?.call(singleNode)
            : existExpandableButton
                ? computePaddingForLeaf(singleNode.level)
                : computePaddingForLeafWithoutExpandable(singleNode.level)))!;
    indent = indent + extraLeftIndent;
    Widget? trailing = configuration.leafConfiguration.trailing
        ?.call(singleNode, indent, context);
    return Row(
      children: <Widget>[
        configuration.leafConfiguration.leading(singleNode, indent, context),
        configuration.leafConfiguration.content(singleNode, indent, context),
        if (trailing != null) trailing,
      ],
    );
  }
}
