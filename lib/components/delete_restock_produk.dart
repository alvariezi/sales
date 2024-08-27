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
      title: const Row(
        children: [
          Icon(Icons.delete, color: Colors.redAccent, size: 30),
          SizedBox(width: 8),
           Text(
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
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.blueAccent),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.blueAccent),
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
