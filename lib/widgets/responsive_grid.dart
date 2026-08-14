import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int desktopColumns;
  final int tabletColumns;
  final int mobileColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 14,
    this.runSpacing = 14,
    this.desktopColumns = 4,
    this.tabletColumns = 2,
    this.mobileColumns = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width >= 1100) {
          columns = desktopColumns;
        } else if (width >= 650) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        final itemWidth =
            (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
