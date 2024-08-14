import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<void> _submitData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'kode_produk': kodeController.text,
          'nama_produk': namaController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        onConfirm();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item: ${response.statusCode}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Item'),
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
            _submitData(context);
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
