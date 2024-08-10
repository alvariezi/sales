import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales/components/delete_restock_produk.dart';
import 'package:sales/screens/add_stock.dart';
import 'package:sales/screens/stock_produk_page.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final List<Map<String, dynamic>> stockHistory = [
    {'kode_restok': 'RS001', 'jumlah_produk': '5', 'tanggal': '2023-12-05T14:30:00'},
    {'kode_restok': 'RS002', 'jumlah_produk': '5', 'tanggal': '2023-12-15T08:15:00'},
    {'kode_restok': 'RS003', 'jumlah_produk': '5', 'tanggal': '2023-12-25T18:45:00'},
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
        return stock['kode_restok']!.toLowerCase().contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void navigateToAddStock() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStockPage()),
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  void navigateToProductDetails(String kodeRestok, String jumlahProduk) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          kodeRestok: kodeRestok,
          jumlahProduk: jumlahProduk,
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(String kodeRestok) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteRestock(
          kodeRestok: kodeRestok,
          onConfirm: () {
            setState(() {
              stockHistory.removeWhere((stock) => stock['kode_restok'] == kodeRestok);
              searchResults = stockHistory;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                              labelText: 'Cari Kode Restock',
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
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
                        const SizedBox(height: 16.0),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Kode Restock')),
                                DataColumn(label: Text('Jumlah Produk')),
                                DataColumn(label: Text('Tanggal & Waktu')),
                                DataColumn(label: Text('Actions')), 
                              ],
                              rows: searchResults.map((stock) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(stock['kode_restok'])),
                                    DataCell(
                                      Text('${stock['jumlah_produk']} item'),
                                      onTap: () {
                                        navigateToProductDetails(
                                          stock['kode_restok'],
                                          stock['jumlah_produk'],
                                        );
                                      },
                                    ),
                                    DataCell(Text(formatDateTime(stock['tanggal']))),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDeleteConfirmationDialog(stock['kode_restok']);
                                        },
                                      ),
                                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddStock,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
