import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales/screens/stock_produk_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales/components/delete_confirmation_dialog.dart';
import 'package:sales/screens/add_stock.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Map<String, dynamic>> stockHistory = [];
  final TextEditingController searchController = TextEditingController();
  String? filterQuery;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> debugPrintToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    debugPrint('Token: $token');
  }

  void addStock(Map<String, dynamic> stock) {
    setState(() {
      stockHistory.add(stock);
      searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil menambahkan stok'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void deleteStock(String kodeRestok) {
    setState(() {
      stockHistory.removeWhere((stock) => stock['kode_restok'] == kodeRestok);
    });
  }

  void showAddStockDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStockPage()),
    );
  }

  void showDeleteConfirmationDialog(String kodeRestok) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          onConfirm: () {
            deleteStock(kodeRestok);
          },
        );
      },
    );
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

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredStockHistory = filterQuery == null
        ? stockHistory
        : stockHistory
            .where((stock) =>
                stock['kode_restok']
                    .toLowerCase()
                    .contains(filterQuery!.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: debugPrintToken,
          ),
        ],
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
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            labelText: 'Cari Kode Restock',
                            suffixIcon: Icon(Icons.search),
                          ),
                          onChanged: (query) {
                            setState(() {
                              filterQuery = query;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
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
                              rows: filteredStockHistory.map((stock) {
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
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              showDeleteConfirmationDialog(stock['kode_restok']);
                                            },
                                          ),
                                        ],
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
        onPressed: showAddStockDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
