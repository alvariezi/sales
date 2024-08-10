import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;

  const CustomDialog({Key? key, required this.title, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // gg color
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
