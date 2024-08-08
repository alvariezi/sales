import 'package:flutter/material.dart';

class SalesDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController alamatController;
  final TextEditingController phoneController;
  final VoidCallback onConfirm;
  final String title;
  final String confirmText;

  const SalesDialog({
    Key? key,
    required this.nameController,
    required this.alamatController,
    required this.phoneController,
    required this.onConfirm,
    required this.title,
    required this.confirmText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Sales',
            ),
          ),
          TextField(
            controller: alamatController,
            decoration: const InputDecoration(
              labelText: 'Alamat Toko',
            ),
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'No HP',
            ),
            keyboardType: TextInputType.phone,
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
            Navigator.pop(context); // Close the dialog after confirming
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}