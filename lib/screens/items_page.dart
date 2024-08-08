// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../components/add_item_dialog.dart';
import '../components/edit_item_dialog.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _kodeBarangController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _namaBarangController.dispose();
    _kodeBarangController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add({
        'nama': _namaBarangController.text,
        'kode': _kodeBarangController.text,
      });
      _namaBarangController.clear();
      _kodeBarangController.clear();
    });
  }

  void _editItem(int index) {
    setState(() {
      _items[index] = {
        'nama': _namaBarangController.text,
        'kode': _kodeBarangController.text,
      };
      _namaBarangController.clear();
      _kodeBarangController.clear();
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
          namaController: _namaBarangController,
          kodeController: _kodeBarangController,
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
          namaController: _namaBarangController,
          kodeController: _kodeBarangController,
          onConfirm: () => _editItem(index),
        );
      },
    );
  }

  void _startEditing(int index) {
    setState(() {
      _namaBarangController.text = _items[index]['nama'];
      _kodeBarangController.text = _items[index]['kode'];
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
                                            onPressed: () =>
                                                _showEditDialog(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                _deleteItem(index),
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