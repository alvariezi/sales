import 'package:flutter/material.dart';
import 'package:sales/screens/add_stock.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final List<Map<String, dynamic>> stockHistory = [
    // List data
    {'kode_barang': '001', 'nama_produk': 'kecap', 'qty_gudang': '50', 'qty_sales': '40', 'id': '1001', 'createdAt': '2023-12-01', 'updatedAt': '2023-12-05'},
    {'kode_barang': '002', 'nama_produk': 'gula', 'qty_gudang': '70', 'qty_sales': '50', 'id': '1002', 'createdAt': '2023-12-10', 'updatedAt': '2023-12-15'},
    {'kode_barang': '003', 'nama_produk': 'garam', 'qty_gudang': '90', 'qty_sales': '60', 'id': '1003', 'createdAt': '2023-12-20', 'updatedAt': '2023-12-25'},
    {'kode_barang': '004', 'nama_produk': 'saos', 'qty_gudang': '60', 'qty_sales': '30', 'id': '1004', 'createdAt': '2023-12-22', 'updatedAt': '2023-12-26'},
    {'kode_barang': '005', 'nama_produk': 'masako', 'qty_gudang': '80', 'qty_sales': '20', 'id': '1005', 'createdAt': '2023-12-24', 'updatedAt': '2023-12-28'},
  ];

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    searchResults = stockHistory;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchStock() {
    setState(() {
      searchResults = stockHistory.where((stock) {
        return stock['nama_produk']!.toLowerCase().contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void navigateToAddStock() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStockPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              labelText: 'Cari Produk',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: searchStock,
                              ),
                            ),
                            onChanged: (value) {
                              searchStock();
                            },
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: navigateToAddStock,
                          child: const Text('Input Data Stock'),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Kode Produk')),
                                DataColumn(label: Text('Nama Produk')),
                                DataColumn(label: Text('Qty Gudang')),
                                DataColumn(label: Text('Qty Sales')),
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Created At')),
                                DataColumn(label: Text('Updated At')),
                              ],
                              rows: searchResults.map((stock) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(stock['kode_barang'])),
                                    DataCell(Text(stock['nama_produk'])),
                                    DataCell(Text(stock['qty_gudang'])),
                                    DataCell(Text(stock['qty_sales'])),
                                    DataCell(Text(stock['id'])),
                                    DataCell(Text(stock['createdAt'])),
                                    DataCell(Text(stock['updatedAt'])),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
