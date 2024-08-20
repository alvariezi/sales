import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sales/components/delete_restock_produk.dart';
import 'package:sales/screens/add_stock.dart';
import 'package:sales/screens/stock_produk_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

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
              '_id': stock['_id'],
              'kode_restock': stock['kode_restock'],
              'list_produk': stock['list_produk'],
              'updatedAt': stock['updatedAt'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStock(String idRestok, List<Map<String, dynamic>> listProduk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token tidak ditemukan.'),
        ),
      );
      return;
    }

    final isValidId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(idRestok);
    if (!isValidId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID format tidak valid.'),
        ),
      );
      return;
    }

    final url = 'https://backend-sales-pearl.vercel.app/api/owner/restock/$idRestok';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        stockHistory.removeWhere((stock) => stock['_id'] == idRestok);
      });
      for (var produk in listProduk) {
        await _updateQtyGudang(produk['id_produk'], produk['qty']);
      }
      Navigator.of(context).pop(); 
      _showSuccessPopup('Data berhasil dihapus');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data. Coba lagi.'),
        ),
      );
    }
  }

  Future<void> _updateQtyGudang(String idProduk, int qty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return;
    }

    final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory/$idProduk';
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'qty_gudang': -qty, 
      }),
    );

    if (response.statusCode == 200) {
      print('qty_gudang berhasil diperbarui.');
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
                        labelText: 'Cari Restock',
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
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
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
                                          _deleteStock(stock['_id'], listProduk.cast<Map<String, dynamic>>());
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
            MaterialPageRoute(
              builder: (context) => const AddStockPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            height: 48.0,
            color: Colors.white,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  height: 80.0,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
