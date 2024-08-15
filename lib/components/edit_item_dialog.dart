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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.blueAccent, size: 30),
          const SizedBox(width: 8),
          const Text(
            'Edit Item',
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
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
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
          onPressed: () {
            onConfirm();
          },
          child: const Text('Update'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
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
