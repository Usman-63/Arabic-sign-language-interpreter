import 'package:flutter/material.dart';

class SelectModel extends StatelessWidget {
  final void Function(String model) onModelSelected;
  const SelectModel({super.key, required this.onModelSelected});

  @override
  Widget build(BuildContext context) {
    String? selectedModel;

    return AlertDialog(
      title: const Text('Select Model'),
      content: StatefulBuilder(
        builder:
            (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Alphabet'),
                  value: 'alphabet',
                  groupValue: selectedModel,
                  onChanged: (value) => setState(() => selectedModel = value),
                ),
                RadioListTile<String>(
                  title: const Text('Phrase'),
                  value: 'word',
                  groupValue: selectedModel,
                  onChanged: (value) => setState(() => selectedModel = value),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      selectedModel == null
                          ? null
                          : () {
                            onModelSelected(selectedModel!);
                            Navigator.of(context).pop();
                          },
                  child: const Text('Continue'),
                ),
              ],
            ),
      ),
    );
  }
}
