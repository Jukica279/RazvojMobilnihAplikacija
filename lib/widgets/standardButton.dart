import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final bool selected;

  const StandardButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (selected) {
          print(1);
        } else {
          onPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected ? const Color.fromARGB(255, 31, 73, 32) : Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: icon,
    );
  }
}
