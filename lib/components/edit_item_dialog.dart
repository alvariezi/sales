import 'package:flutter/material.dart';

class EditItemDialog extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController kodeController;
  final VoidCallback onConfirm;

  const EditItemDialog({
    Key? key,
    required this.namaController,
    required this.kodeController,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Barang',
            ),
          ),
          TextField(
            controller: kodeController,
            decoration: const InputDecoration(
              labelText: 'Kode Barang',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}