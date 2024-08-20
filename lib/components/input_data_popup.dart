import 'package:flutter/material.dart';
import 'package:sales/screens/stock_history.dart';

Future<void> showSuccessPopup(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          'Data berhasil di tambahkan',
          textAlign: TextAlign.center, 
          style: const TextStyle(
            fontSize: 16, 
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StockPage()),
                ); // Navigate to StockPage
              },
              child: const Text('Tutup'),
            ),
        ],
      );
    },
  );
}
