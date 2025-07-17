import 'package:flutter/material.dart';

class SelectCamera extends StatelessWidget {
  final void Function(String direction) onCameraSelected;
  const SelectCamera({super.key, required this.onCameraSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Camera'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_front),
            title: const Text('Front Camera'),
            onTap: () {
              onCameraSelected("front");
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_rear),
            title: const Text('Back Camera'),
            onTap: () {
              onCameraSelected("back");
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
