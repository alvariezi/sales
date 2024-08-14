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

  void _addItem() {
    setState(() {
      _items.add({
        'nama': _namaProdukController.text,
        'kode': _kodeProdukController.text,
      });
      _namaProdukController.clear();
      _kodeProdukController.clear();
    });
  }

  void _editItem(int index) {
    setState(() {
      _items[index] = {
        'nama': _namaProdukController.text,
        'kode': _kodeProdukController.text,
      };
      _namaProdukController.clear();
      _kodeProdukController.clear();
      _editingIndex = null;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          namaController: _namaProdukController,
          kodeController: _kodeProdukController,
          onConfirm: _addItem,
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
          onConfirm: () => _editItem(index),
        );
      },
    );
  }

  void _startEditing(int index) {
    setState(() {
      _namaProdukController.text = _items[index]['nama'];
      _kodeProdukController.text = _items[index]['kode'];
      _editingIndex = index;
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
