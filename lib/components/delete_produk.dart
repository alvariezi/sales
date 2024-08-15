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
      title: const Text('Konfirmasi Hapus'),
      content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
