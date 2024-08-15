import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/add_item_dialog.dart';
import '../components/edit_item_dialog.dart';
import 'package:shimmer/shimmer.dart';
import '../components/delete_produk.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<Map<String, dynamic>> _items = [];
   bool _isLoading = true; 
   final List<Map<String, dynamic>> _filteredItems = [];
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _kodeProdukController = TextEditingController();
  int? _editingIndex;
  String? _editingItemId;
    final TextEditingController _searchController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _fetchItemsFromApi();
     _searchController.addListener(_filterItems);
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
           _filteredItems.clear();
          for (var item in inventory) {
            _items.add({
              '_id': item['_id'] ?? '', 
              'kode': item['kode_produk'] ?? '',
              'nama': item['nama_produk'] ?? '',
            });
            _filteredItems.add({
              'kode': item['kode_produk'] ?? '',
              'nama': item['nama_produk'] ?? '',
            }); 
          }
          _isLoading = false; 
        });
      } else {
        print('Failed to load items');
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


   void _filterItems() {
    setState(() {
      _filteredItems.clear();
      _filteredItems.addAll(_items.where((item) {
        final namaLower = item['nama']?.toLowerCase() ?? '';
        final kodeLower = item['kode']?.toLowerCase() ?? '';
        final searchLower = _searchController.text.toLowerCase();
        return namaLower.contains(searchLower) || kodeLower.contains(searchLower);
      }).toList());
    });
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

    if (response.statusCode == 200 || response.statusCode == 201) { 
      final newItem = jsonDecode(response.body);

      setState(() {
        _items.add({
          '_id': newItem['_id'] ?? '', 
          'kode': newItem['kode_produk'] ?? '',
          'nama': newItem['nama_produk'] ?? '',
        });
      });

      await _fetchItemsFromApi(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: ${response.statusCode}')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No token found')),
    );
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
      await _fetchItemsFromApi(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No token found')),
    );
  }
}


  void _deleteItem(int index) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  
  if (token != null) {
    final itemId = _items[index]['_id'];
    final url = 'https://backend-sales-pearl.vercel.app/api/owner/inventory/delete/$itemId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _items.removeAt(index);
        _filteredItems.removeAt(index); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
      await _fetchItemsFromApi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No token found')),
    );
  }
}


 void _confirmDeleteItem(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return ConfirmDeleteDialog(
        onConfirm: () {
          Navigator.of(context).pop();
          _deleteItem(index);
        },
        onCancel: () {
          Navigator.of(context).pop(); 
        },
      );
    },
  );
}


  void _showAddDialog() {
     _namaProdukController.clear();
  _kodeProdukController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          namaController: _namaProdukController,
          kodeController: _kodeProdukController,
          onConfirm: () async {
            await _addItem();
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
            if (mounted) {
              Navigator.pop(context); 
            }
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
              if (_isLoading) {
                return _buildSkeletonLoading();
              } else {
                return Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Cari Produk',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildDataTable()),
                  ],
                );
              }
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

  Widget _buildSkeletonLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nama Barang')),
          DataColumn(label: Text('Kode Barang')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List<DataRow>.generate(
          5,
          (index) => DataRow(
            cells: [
              DataCell(Container(
                width: 100,
                height: 20,
                color: Colors.white,
              )),
              DataCell(Container(
                width: 100,
                height: 20,
                color: Colors.white,
              )),
              DataCell(Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
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
                    rows:  _filteredItems.map((item) {
                      int index = _filteredItems.indexOf(item);
                      return DataRow(
                        cells: [
                          DataCell(Text(item['nama'] ?? '')),
                          DataCell(Text(item['kode'] ?? '')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteItem(index),
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
  }
}