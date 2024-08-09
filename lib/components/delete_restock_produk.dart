import 'package:flutter/material.dart';

class DeleteRestock extends StatelessWidget {
  final String kodeRestok;
  final VoidCallback onConfirm;

  const DeleteRestock({
    Key? key,
    required this.kodeRestok,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi delete data!!'),
      content: Text('Apakah anda yakin ingin menghapus $kodeRestok?'),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Red background for Cancel button
            foregroundColor: Colors.white, // White text
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Green background for Confirm button
            foregroundColor: Colors.white, // White text
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
