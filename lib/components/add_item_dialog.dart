import 'package:flutter/material.dart';

class AddItemDialog extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController kodeController;
  final VoidCallback onConfirm;

  const AddItemDialog({
    Key? key,
    required this.namaController,
    required this.kodeController,
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
          Icon(Icons.add, color: Colors.green, size: 30),
          const SizedBox(width: 8),
          const Text(
            'Tambah Barang',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Barang',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: kodeController,
            decoration: const InputDecoration(
              labelText: 'Kode Barang',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.green),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.green),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
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
