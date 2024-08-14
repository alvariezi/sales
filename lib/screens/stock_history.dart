import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  void initState() {
    super.initState();
    _fetchStockHistoryFromApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStockHistoryFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      const url = 'https://backend-sales-pearl.vercel.app/api/owner/restock';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse["history_stok"]);
        final List<dynamic> responseData = jsonResponse["history_stok"];
        debugPrint('$responseData');
        setState(() {
          stockHistory = responseData.map((stock) {
            return {
              'kode_restock': stock['kode_restock'],
              'list_produk': stock['list_produk'],
              'updatedAt': stock['updatedAt'],
            };
          }).toList();
        });
      } else {
        debugPrint('Failed to load stock');
      }
    }
  }

  void addStock(Map<String, dynamic> stock) {
    setState(() {
      stockHistory.add(stock);
      searchController.clear();
    });
  }

  void deleteStock(String kodeRestock) {
    setState(() {
      stockHistory.removeWhere((stock) => stock['kode_restock'] == kodeRestock);
    });
  }

  void showAddStockDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStockPage()),
    );
  }

  void showDeleteConfirmationDialog(String kodeRestock) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          onConfirm: () {
            deleteStock(kodeRestock);
          },
        );
      },
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  void navigateToProductDetailsPage(
      String kodeRestock, List<dynamic> listProduk) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          kodeRestok: kodeRestock,
          productDetails: listProduk,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredStockHistory = filterQuery == null
        ? stockHistory
        : stockHistory
            .where((stock) =>
                stock['kode_restock']
                    .toLowerCase()
                    .contains(filterQuery!.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              debugPrint('Token: $token');
            },
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
                                DataColumn(label: Text('Tanggal')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredStockHistory.map((stock) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(stock['kode_restock'])),
                                    DataCell(
                                      GestureDetector(
                                        onTap: () {
                                          navigateToProductDetailsPage(
                                            stock['kode_restock'],
                                            stock['list_produk'],
                                          );
                                        },
                                        child: Text(
                                          '${(stock['list_produk'] as List<dynamic>).length} items',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            // Removed the underline from the text
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                        formatDateTime(stock['updatedAt']))),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              showDeleteConfirmationDialog(
                                                  stock['kode_restock']);
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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }
}
