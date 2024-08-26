import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const SuccessDialog({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      content: Text(
          message,
          textAlign: TextAlign.center, 
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 17.0, 
          ),
        ),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: onClose,
            child: const Text('Tutup'),
        ),
        )
      ],
    );
  }
}
