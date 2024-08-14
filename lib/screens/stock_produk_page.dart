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
        title: Text('Detail Stock: $kodeRestok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Kode barang')),
                    DataColumn(label: Text('Nama barang')),
                    DataColumn(label: Text('Qty')), 
                  ],
                  rows: productDetails.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Text(product['kode_produk'])),
                        DataCell(Text(product['nama_produk'])),
                        DataCell(Text(product['qty'].toString())), 
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
