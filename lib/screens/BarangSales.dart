import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BarangSales extends StatefulWidget {
  @override
  _BarangSalesState createState() => _BarangSalesState();
}

class _BarangSalesState extends State<BarangSales> {
  String? _selectedSalesId;
  List<Map<String, String>> _salesOptions = [];
  List<Map<String, String>> _productOptions = [];
  List<Map<String, String>> _selectedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalesOptions();
    _fetchProductOptions();
  }

  Future<void> _fetchSalesOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('https://backend-sales-pearl.vercel.app/api/owner/sales'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> salesData = data['data'];

        setState(() {
          _salesOptions = salesData.map<Map<String, String>>((sales) {
            return {
              'id_sales': sales['sales']['_id'],
              'name': sales['sales']['username'] ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load sales');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data sales')),
      );
    }
  }

  Future<void> _fetchProductOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('https://backend-sales-pearl.vercel.app/api/owner/inventory'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productData = data['inventory'];

        setState(() {
          _productOptions = productData.map<Map<String, String>>((product) {
            return {
              'id_produk': product['_id'],
              'kode_produk': product['kode_produk'] ?? '',
              'nama_produk': product['nama_produk'] ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data produk')),
      );
    }
  }

  Future<void> _addBarang() async {
    if (_selectedSalesId == null || _selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap pilih sales dan produk')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(
            'https://backend-sales-pearl.vercel.app/api/owner/sales/inventory/$_selectedSalesId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "data": _selectedProducts,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barang berhasil ditambahkan')),
        );
        setState(() {
          _selectedProducts = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan barang')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSalesId,
                    hint: Text('Pilih Sales'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSalesId = newValue;
                      });
                    },
                    items: _salesOptions.map<DropdownMenuItem<String>>(
                        (Map<String, String> sales) {
                      return DropdownMenuItem<String>(
                        value: sales['id_sales'],
                        child: Text(sales['name']!),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Pilih Produk:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _productOptions.length,
                      itemBuilder: (context, index) {
                        final product = _productOptions[index];
                        return CheckboxListTile(
                          title: Text(product['nama_produk']!),
                          subtitle: Text(product['kode_produk']!),
                          value: _selectedProducts.contains(product),
                          onChanged: (bool? isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _selectedProducts.add(product);
                              } else {
                                _selectedProducts.remove(product);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBarang,
                    child: Text('Tambah Barang'),
                  ),
                ],
              ),
      ),
    );
  }
}
