import 'package:flutter/material.dart';

class DeleteRestock extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteRestock({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Close the dialog without confirmation
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(); // Call the confirmation callback
            Navigator.of(context).pop(true); // Close the dialog with confirmation
          },
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
