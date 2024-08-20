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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Row(
        children: [
          Icon(Icons.delete, color: Colors.redAccent, size: 30),
          const SizedBox(width: 8),
          const Text(
            'Konfirmasi Hapus',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'Apakah Anda yakin ingin menghapus data ini?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Cancel
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
          },
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}

