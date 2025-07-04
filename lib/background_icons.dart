import 'package:flutter/material.dart';

class BackgroundIconData {
  final IconData icon;
  final double size;
  final double angle;
  final double left;
  final double? top;
  final double? right;
  final double? bottom;
  final Color color;

  const BackgroundIconData({
    required this.icon,
    required this.size,
    required this.angle,
    this.left = 0,
    this.top,
    this.right,
    this.bottom,
    this.color = const Color(0x22000000),
  });
}

class BackgroundIcons extends StatelessWidget {
  final List<BackgroundIconData> icons;

  const BackgroundIcons({super.key, required this.icons});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children:
            icons.map((iconData) {
              return Positioned(
                left: iconData.left,
                top: iconData.top,
                right: iconData.right,
                bottom: iconData.bottom,
                child: Transform.rotate(
                  angle: iconData.angle,
                  child: Icon(
                    iconData.icon,
                    size: iconData.size,
                    color: iconData.color,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
