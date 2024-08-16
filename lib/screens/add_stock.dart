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

  final Map<String, Map<String, String>> _productData = {
    'mie': {'id_produk': '66b44cfdd052a945fbac0644', 'kode_produk': 'P101'},
    'wafer': {'id_produk': '66b44d0bd052a945fbac0649', 'kode_produk': 'P102'},
    'nastar': {'id_produk': '66b44d0bd052a945fbac0675', 'kode_produk': 'P103'},
    'gula': {'id_produk': '66b44d0bd052a945fbac0641', 'kode_produk': 'P104'},
    'garam': {'id_produk': '66b44d0bd052a945fbac0667', 'kode_produk': 'P105'},
    // Add more products as needed
  };

  @override
  void initState() {
    super.initState();
    _addForm();
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
          // Show success popup
          showSuccessPopup(
            context,
            'Data berhasil ditambahkan',
          );
        } else {
          showSuccessPopup(
            context,
            '',
          );
        }
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
                                      ? 'Nama produk harus terisi'
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
