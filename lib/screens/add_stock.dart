// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _formData = [];

  final Map<String, Map<String, String>> _productData = {
    'mie': {'id_produk': '66b44cfdd052a945fbac0644', 'kode_produk': 'P101'},
    'wafer': {'id_produk': '66b44d0bd052a945fbac0649', 'kode_produk': 'P102'},
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
        'namaProdukController': TextEditingController(),
        'qtyController': TextEditingController(),
      });
    });
  }

  void _removeForm(int index) {
    setState(() {
      _formData[index]['namaProdukController'].dispose();
      _formData[index]['qtyController'].dispose();
      _formData.removeAt(index);
    });
  }

  void _fillProductDetails(int index) {
    final namaProduk = _formData[index]['namaProdukController'].text;
    if (_productData.containsKey(namaProduk)) {
      setState(() {
        _formData[index]['idProduk'] = _productData[namaProduk]!['id_produk'];
        _formData[index]['kodeProduk'] = _productData[namaProduk]!['kode_produk'];
      });
    }
  }

  Future<void> addStock() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token != null) {
        const url = 'https://backend-sales-pearl.vercel.app/api/owner/restock';
        final List<Map<String, dynamic>> listProduk = _formData.map((data) {
          return {
            'id_produk': data['idProduk'],
            'kode_produk': data['kodeProduk'],
            'nama_produk': data['namaProdukController'].text,
            'qty': int.parse(data['qtyController'].text),
          };
        }).toList();

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
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi tambah'),
                content: const Text('Apakah data yang anda tambahkan benar?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          if (result == true) {
            Navigator.pop(context);
          }
        } else {
          print('Failed to add stock: ${response.body}');
        }
      }
    }
  }

  @override
  void dispose() {
    _formData.forEach((data) {
      data['namaProdukController'].dispose();
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
                              child: TextFormField(
                                controller: data['namaProdukController'],
                                decoration: const InputDecoration(
                                  labelText: 'Nama Produk',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  _fillProductDetails(index);
                                },
                                validator: (value) {
                                  return value == null || value.isEmpty
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
