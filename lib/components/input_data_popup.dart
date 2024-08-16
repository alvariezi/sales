import 'package:flutter/material.dart';
import 'package:sales/screens/stock_history.dart';

Future<void> showSuccessPopup(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Icon(Icons.check_circle, color: Colors.green, size: 60),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Ensure content size is based on its children
          children: [
            Text(
              'Data berhasil di tambahkan',
              textAlign: TextAlign.center, // Center text horizontally
              style: TextStyle(
                color: Colors.black, // Text color
                fontWeight: FontWeight.bold, // Bold text
                fontSize: 16, // Adjust font size if needed
              ),
            ),
            const SizedBox(height: 8.0), // Adjust space between text and button
          ],
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Button background color
                onPrimary: Colors.white, // Button text color
              ),
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StockPage()),
                ); // Navigate to StockPage
              },
            ),
          ),
        ],
      );
    },
  );
}
