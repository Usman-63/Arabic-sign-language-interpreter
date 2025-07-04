import 'dart:ui';

import 'package:flutter/material.dart';

class StartLearningHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtentHeight;
  final double maxExtentHeight;
  final VoidCallback onPressed;

  StartLearningHeaderDelegate({
    required this.minExtentHeight,
    required this.maxExtentHeight,
    required this.onPressed,
  });

  @override
  double get minExtent => minExtentHeight;
  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Calculate the percent the header is shrunk
    final percent = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Use lerpDouble to interpolate values based on the shrink percentage
    final double buttonWidth = lerpDouble(320, 160, percent)!;
    final double buttonHeight = lerpDouble(56, 40, percent)!;
    final double fontSize = lerpDouble(18, 14, percent)!;

    return Container(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 24, right: 24, left: 24, bottom: 8),
          child: SizedBox(
            width: buttonWidth * 1.1,
            height: buttonHeight * 1.1,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                'Start Learning',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7E22CE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StartLearningHeaderDelegate oldDelegate) => true;
}

class AppBarHeader extends StatelessWidget {
  const AppBarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
