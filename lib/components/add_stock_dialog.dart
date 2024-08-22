import 'package:flutter/material.dart';

class AddStockDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const AddStockDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 18.0),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false to indicate cancellation
          },
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.green),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.green),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true); // Return true to indicate confirmation
          },
          child: const Text('Tambah'),
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}
