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
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockHistoryFromApi();
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
              'createdAt': stock['createdAt'],
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
    }
  }

 Future<void> _selectDateRange(BuildContext context) async {
  if (stockHistory.isEmpty) return;

  // Mengambil tanggal pertama dan terakhir dari stockHistory
  DateTime firstDate = DateTime.parse(stockHistory.first['createdAt']).toLocal();
  DateTime lastDate = DateTime.parse(stockHistory.last['createdAt']).toLocal();

  final DateTimeRange? pickedDateRange = await showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate.isAfter(DateTime.now()) ? DateTime.now() : lastDate,
    initialDateRange: DateTimeRange(
      start: startDate ?? firstDate,
      end: endDate ?? lastDate,
    ),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.blue, 
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white, 
            onSurface: Colors.blue, 
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary, 
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDateRange != null) {
    setState(() {
      startDate = pickedDateRange.start;
      endDate = pickedDateRange.end;
    });
  }
}

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime); 
    return '$formattedDate'; 
  }


  @override
  Widget build(BuildContext context) {
    final filteredStockHistory = startDate == null || endDate == null
    ? stockHistory
    : stockHistory.where((stock) {
        DateTime stockDate = DateTime.parse(stock['createdAt']).toLocal();
        return stockDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
               stockDate.isBefore(endDate!.add(Duration(days: 1)));
      }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Restock'),
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
                    ElevatedButton(
                      onPressed: () => _selectDateRange(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white, 
                        onPrimary: Colors.blue, 
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (startDate == null || endDate == null) 
                            Icon(Icons.search, color: Colors.blue), 
                          const SizedBox(width: 5.0), 
                          Text(
                            startDate == null || endDate == null
                                ? 'Cari Restock'
                                : 'Restock: ${DateFormat('dd-MM-yyyy').format(startDate!)} s.d. ${DateFormat('dd-MM-yyyy').format(endDate!)}',
                            style: TextStyle(
                              color: startDate == null || endDate == null ? Colors.grey : Colors.blue, 
                            ),
                          ),
                          if (startDate != null && endDate != null)
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.grey), 
                              onPressed: () {
                                setState(() {
                                  startDate = null;
                                  endDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredStockHistory.length,
                        itemBuilder: (context, index) {
                          final stock = filteredStockHistory[index];
                          final listProduk = stock['list_produk'] as List<dynamic>;
                          return Card(
                            elevation: 1.0,  
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stock Tanggal : ${formatDateTime(stock['createdAt'] ?? '')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '${listProduk.length} items',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Kode Restock : ${stock['kode_restock'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
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
                            ),
                          );
                        },
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
              builder: (context) => AddStockPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Container(
                height: 20.0,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Container(
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    height: 14.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
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