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
      title: const Text('Konfirmasi Hapus'),
      content: Text('Apakah anda yakin ingin menghapus $kodeRestok?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // bg button
            foregroundColor: Colors.white, // color text
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
