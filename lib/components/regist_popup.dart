import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;

  const SuccessDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selamat!!', style: TextStyle(color: Colors.blue),),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}