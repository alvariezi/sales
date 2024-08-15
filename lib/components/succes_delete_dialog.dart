import 'package:flutter/material.dart';

class SuccessDeleteDialog extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const SuccessDeleteDialog({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
