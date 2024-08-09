import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final String kodeRestok;
  final String jumlahProduk;

  const ProductDetailsPage({
    Key? key,
    required this.kodeRestok,
    required this.jumlahProduk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Manual data
    List<Map<String, dynamic>> productDetails = [
      {'kode_produk': 'P001', 'nama_produk': 'kopi', 'jumlah_produk': '30'},
      {'kode_produk': 'P002', 'nama_produk': 'saos tomat', 'jumlah_produk': '55'},
      {'kode_produk': 'P003', 'nama_produk': 'saos sambal', 'jumlah_produk': '70'},
      {'kode_produk': 'P004', 'nama_produk': 'garam', 'jumlah_produk': '70'},
      {'kode_produk': 'P005', 'nama_produk': 'gula', 'jumlah_produk': '75'},
      // Add more products as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Stock: $kodeRestok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Kode')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Jumlah')),
                  ],
                  rows: productDetails.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Text(product['kode_produk'])),
                        DataCell(Text(product['nama_produk'])),
                        DataCell(Text(product['jumlah_produk'])),
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
