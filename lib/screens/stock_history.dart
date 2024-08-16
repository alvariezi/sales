import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sales/components/delete_restock_produk.dart';
import 'package:sales/components/input_data_popup.dart';
import 'package:sales/screens/stock_produk_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'add_stock.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Map<String, dynamic>> stockHistory = [];
  final TextEditingController searchController = TextEditingController();
  String? filterQuery;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockHistoryFromApi();
    searchController.addListener(_filterItems);
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
        final List<dynamic> responseData = jsonResponse["history_stok"];
        setState(() {
          stockHistory = responseData.map((stock) {
            return {
              'kode_restock': stock['kode_restock'],
              'list_produk': stock['list_produk'],
              'updatedAt': stock['updatedAt'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load stock');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No token found');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStock(String kodeRestock) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/restock/$kodeRestock';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          stockHistory.removeWhere((stock) => stock['kode_restock'] == kodeRestock);
        });
        Navigator.of(context).pop(); 
        showSuccessPopup(context, 'Data berhasil dihapus'); 
      } else {
        print('Failed to delete stock');
      }
    }
  }

  void _filterItems() {
    setState(() {
      filterQuery = searchController.text;
    });
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  @override
  Widget build(BuildContext context) {
    final filteredStockHistory = filterQuery == null
        ? stockHistory
        : stockHistory.where((stock) =>
            stock['kode_restock'].toLowerCase().contains(filterQuery!.toLowerCase())
        ).toList();

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
              if (_isLoading) {
                return _buildSkeletonLoading();
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Cari Produk',
                        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Kode Restock',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Jumlah Produk',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Tanggal',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: filteredStockHistory.map((stock) {
                            final listProduk = stock['list_produk'] as List<dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(stock['kode_restock'] ?? '')),
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailsPage(
                                            kodeRestok: stock['kode_restock'],
                                            productDetails: listProduk,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${listProduk.length} items',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                DataCell(Text(formatDateTime(stock['updatedAt'] ?? ''))),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final bool? shouldDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DeleteRestock(
                                            onConfirm: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          );
                                        },
                                      );
                                      if (shouldDelete == true) {
                                        _deleteStock(stock['kode_restock']);
                                      }
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
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStockPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Container(
                color: Colors.white,
                height: 16,
                width: double.infinity,
              ),
              subtitle: Container(
                color: Colors.white,
                height: 14,
                width: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }
}
