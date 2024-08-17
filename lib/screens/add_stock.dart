import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sales/components/input_data_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddStockPage extends StatefulWidget {
  const AddStockPage({Key? key}) : super(key: key);

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _formData = [];
  final Map<String, Map<String, dynamic>> _productData = {};

  @override
  void initState() {
    super.initState();
    _fetchProductData();
    _addForm();
  }

  Future<void> _fetchProductData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      const url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> inventory = responseData['inventory'];

        setState(() {
          for (var item in inventory) {
            _productData[item['nama_produk']] = {
              'id_produk': item['_id'],
              'kode_produk': item['kode_produk'],
              'qty_gudang': item['qty_gudang'],
            };
          }
        });
      } else {
        print('Failed to load product data');
      }
    } else {
      print('No token found');
    }
  }

  void _addForm() {
    setState(() {
      _formData.add({
        'selectedProduct': null,
        'qtyController': TextEditingController(),
      });
    });
  }

  void _removeForm(int index) {
    setState(() {
      _formData[index]['qtyController'].dispose();
      _formData.removeAt(index);
    });
  }

  Future<void> addStock() async {
    if (_formKey.currentState?.validate() ?? false) {
      final List<Map<String, dynamic>> listProduk = _formData.map((data) {
        final selectedProduct = data['selectedProduct'];
        final productData = selectedProduct != null ? _productData[selectedProduct] : null;

        return {
          'id_produk': productData?['id_produk'] ?? '',
          'kode_produk': productData?['kode_produk'] ?? '',
          'nama_produk': selectedProduct ?? '',
          'qty': int.tryParse(data['qtyController']?.text ?? '') ?? 0,
        };
      }).toList();

      if (listProduk.any((item) => item['id_produk'].isEmpty || item['kode_produk'].isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data produk tidak lengkap')),
        );
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token != null) {
        final url = 'https://backend-sales-pearl.vercel.app/api/owner/restock';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'list_produk': listProduk,
          }),
        );

        if (response.statusCode == 201) {
          // Update qty_gudang in the inventory
          for (var item in listProduk) {
            await _updateInventoryQty(item['id_produk'], item['qty']);
          }
          // Show success popup
          showSuccessPopup(
            context,
            'Data berhasil ditambahkan',
          );
        } else {
          showSuccessPopup(
            context,
            'Gagal menambahkan data',
          );
        }
      }
    }
  }

  Future<void> _updateInventoryQty(String idProduk, int qty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory/update_qty/$idProduk';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'qty_gudang': qty,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to update qty_gudang');
      }
    }
  }

  @override
  void dispose() {
    _formData.forEach((data) {
      data['qtyController'].dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _formData.length,
                  itemBuilder: (context, index) {
                    final data = _formData[index];
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: data['selectedProduct'],
                                decoration: const InputDecoration(
                                  labelText: 'Nama Produk',
                                  border: OutlineInputBorder(),
                                ),
                                items: _productData.keys.map((productName) {
                                  return DropdownMenuItem<String>(
                                    value: productName,
                                    child: Text(productName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    data['selectedProduct'] = value;
                                  });
                                },
                                validator: (value) {
                                  return value == null
                                      ? 'produk harus terisi'
                                      : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: data['qtyController'],
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? 'Masukkan jumlah'
                                      : null;
                                },
                              ),
                            ),
                            if (index != 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeForm(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
                    onPressed: _addForm,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addStock,
                child: const Text('Tambah Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
