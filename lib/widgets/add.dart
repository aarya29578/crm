import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Add',
      onPressed: onPressed,
      icon: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}