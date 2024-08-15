import 'package:flutter/material.dart';

class AddItemDialog extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController kodeController;
  final VoidCallback onConfirm;

  const AddItemDialog({super.key, 
    required this.namaController,
    required this.kodeController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Barang'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(labelText: 'Nama Barang'),
          ),
          TextField(
            controller: kodeController,
            decoration: const InputDecoration(labelText: 'Kode Barang'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
