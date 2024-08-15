import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/add_item_dialog.dart';
import '../components/edit_item_dialog.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _kodeProdukController = TextEditingController();
  int? _editingIndex;
  String? _editingItemId;

  @override
  void initState() {
    super.initState();
    _fetchItemsFromApi();
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _kodeProdukController.dispose();
    super.dispose();
  }

  Future<void> _fetchItemsFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory';
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
          _items.clear();
          for (var item in inventory) {
            _items.add({
              '_id': item['_id'], 
              'kode': item['kode_produk'],
              'nama': item['nama_produk'],
            });
          }
        });
      } else {
        print('Failed to load items');
      }
    } else {
      print('No token found');
    }
  }

  Future<void> _addItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama_produk': _namaProdukController.text,
          'kode_produk': _kodeProdukController.text,
        }),
      );

      if (response.statusCode == 201) { 
        _fetchItemsFromApi(); 
      } else {
        print('Failed to add item');
      }
    }
  }

  Future<void> _editItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null && _editingItemId != null) {
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory/$_editingItemId';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama_produk': _namaProdukController.text,
          'kode_produk': _kodeProdukController.text,
        }),
      );

      if (response.statusCode == 200) {
        _fetchItemsFromApi(); 
      } else {
        print('Failed to update item');
      }
    }
  }

  void _deleteItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    
    if (token != null) {
      final itemId = _items[index]['_id'];
      final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory/$itemId';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _items.removeAt(index);
        });
      } else {
        print('Failed to delete item');
      }
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          namaController: _namaProdukController,
          kodeController: _kodeProdukController,
          onConfirm: () async {
            await _addItem();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditDialog(int index) {
    _startEditing(index);

    showDialog(
      context: context,
      builder: (context) {
        return EditItemDialog(
          namaController: _namaProdukController,
          kodeController: _kodeProdukController,
          onConfirm: () async {
            await _editItem();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _startEditing(int index) {
    setState(() {
      _namaProdukController.text = _items[index]['nama'];
      _kodeProdukController.text = _items[index]['kode'];
      _editingIndex = index;
      _editingItemId = _items[index]['_id']; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Barang'),
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
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Nama Barang')),
                                DataColumn(label: Text('Kode Barang')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _items.map((item) {
                                int index = _items.indexOf(item);
                                return DataRow(
                                  cells: [
                                    DataCell(Text(item['nama'])),
                                    DataCell(Text(item['kode'])),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _showEditDialog(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _deleteItem(index),
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
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
