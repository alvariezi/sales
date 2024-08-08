// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../components/delete_confirmation_dialog.dart';
import '../components/sales_dialog.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final List<Map<String, dynamic>> _sales = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int? _editingIndex;
  String? _filterQuery;

  @override
  void dispose() {
    _nameController.dispose();
    _alamatController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addSale() {
    setState(() {
      _sales.add({
        'name': _nameController.text,
        'alamat': _alamatController.text,
        'phone': _phoneController.text,
      });
      _nameController.clear();
      _alamatController.clear();
      _phoneController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil menambahkan sales'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editSale(int index) {
    setState(() {
      _sales[index] = {
        'name': _nameController.text,
        'alamat': _alamatController.text,
        'phone': _phoneController.text,
      };
      _nameController.clear();
      _alamatController.clear();
      _phoneController.clear();
      _editingIndex = null;
    });
  }

  void _deleteSale(int index) {
    setState(() {
      _sales.removeAt(index);
    });
  }

  void _startEditing(int index) {
    setState(() {
      _nameController.text = _sales[index]['name'];
      _alamatController.text = _sales[index]['alamat'];
      _phoneController.text = _sales[index]['phone'];
      _editingIndex = index;
    });

    _showEditDialog(index);
  }

  void _showAddDialog() {
    _nameController.clear();
    _alamatController.clear();
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return SalesDialog(
          nameController: _nameController,
          alamatController: _alamatController,
          phoneController: _phoneController,
          onConfirm: _addSale,
          title: 'Tambah Sales',
          confirmText: 'Tambah',
        );
      },
    );
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return SalesDialog(
          nameController: _nameController,
          alamatController: _alamatController,
          phoneController: _phoneController,
          onConfirm: () => _editSale(index),
          title: 'Edit Sales',
          confirmText: 'Update',
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteConfirmationDialog(
          onConfirm: () {
            _deleteSale(index); // Delete the sale if confirmed
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredSales = _filterQuery == null
        ? _sales
        : _sales
            .where((sale) =>
                sale['alamat']
                    .toLowerCase()
                    .contains(_filterQuery!.toLowerCase()) ||
                sale['name'].toLowerCase().contains(_filterQuery!.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales CRUD'),
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
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Cari Sales',
                            suffixIcon: Icon(Icons.search),
                          ),
                          onChanged: (query) {
                            setState(() {
                              _filterQuery = query;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Alamat')),
                                DataColumn(label: Text('Phone Number')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredSales.map((sale) {
                                int index = _sales.indexOf(sale);
                                return DataRow(
                                  cells: [
                                    DataCell(Text(sale['name'])),
                                    DataCell(Text(sale['alamat'] ?? '')),
                                    DataCell(Text(sale['phone'])),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () =>
                                                _startEditing(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                _showDeleteConfirmationDialog(index),
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