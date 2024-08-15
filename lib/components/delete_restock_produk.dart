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
      title: const Text('Konfirmasi Penghapusan'),
      content: const Text('Apakah Anda yakin ingin menghapus stok ini?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Konfirmasi'),
        ),
      ],
    );
  }
}
