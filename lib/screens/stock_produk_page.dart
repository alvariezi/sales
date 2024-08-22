import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final String kodeRestok;
  final List<dynamic> productDetails;

  const ProductDetailsPage({
    Key? key,
    required this.kodeRestok,
    required this.productDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Produk :'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: productDetails.length,
                itemBuilder: (context, index) {
                  final product = productDetails[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        product['nama_produk'] ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product['kode_produk'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold
                              ), 
                          ),
                          Text(
                            'Qty: ${product['qty'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal
                            ), 
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
