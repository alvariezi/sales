import 'package:flutter/material.dart';
import 'package:sales/components/input_data_popup.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({super.key});

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _formData = [];

  // List of product names for the dropdown
  final List<String> productOptions = [
    'Kecap',
    'Gula',
    'Garam',
    'Saos',
    'Masako',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with one form
    _addForm();
  }

  void _addForm() {
    setState(() {
      _formData.add({
        'selectedProduct': null,
        'qtyGudangController': TextEditingController(),
      });
    });
  }

  void _removeForm(int index) {
    setState(() {
      _formData[index]['qtyGudangController'].dispose();
      _formData.removeAt(index);
    });
  }

  void addStock() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      // Handle stock addition logic here
      _formData.forEach((data) {
        print('Nama Produk: ${data['selectedProduct']}');
        print('Qty Gudang: ${data['qtyGudangController'].text}');
      });

      // Message popup input
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(
            title: 'Yakin menambahkan data??',
            message: 'Jika iya klik confirm, Jika tidak klik cancel',
          );
        },
      );

      if (result == true) {
        // Confirm was pressed
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _formData.forEach((data) {
      data['qtyGudangController'].dispose();
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
                                items: productOptions.map((String product) {
                                  return DropdownMenuItem<String>(
                                    value: product,
                                    child: Text(product),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    data['selectedProduct'] = newValue;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Nama Produk',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  return value == null ? 'Produk harus terisi' : null;
                                },
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: data['qtyGudangController'],
                                decoration: InputDecoration(
                                  labelText: 'Qty Gudang',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  return value == null || value.isEmpty ? 'Masukkan jumlah' : null;
                                },
                              ),
                            ),
                            if (index != 0)
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeForm(index),
                              ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.blue, size: 30),
                    onPressed: _addForm,
                  ),
                ],
              ),
              SizedBox(height: 16.0),
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
