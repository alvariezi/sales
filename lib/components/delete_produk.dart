import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDeleteDialog({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
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
        'Apakah Anda yakin ingin menghapus item ini?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.blueAccent),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text(
            'Hapus',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.redAccent,
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
