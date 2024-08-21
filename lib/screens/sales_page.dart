import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import '../components/succes_add_dialog.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHPController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  List<dynamic> _salesList = [];
  bool _isLoading = true;
  String? _currentEditId;

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  Future<void> fetchSales() async {
    final String apiUrl = 'https://backend-sales-pearl.vercel.app/api/owner/sales';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> salesData = jsonResponse['data'];

        setState(() {
          _salesList = salesData;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan!')),
        );
      }
    }
  }

  Future<void> addSales() async {
    final String apiUrl = 'https://backend-sales-pearl.vercel.app/api/owner/sales';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'nama': _namaController.text,
          'noHP': _noHPController.text,
          'alamat': _alamatController.text,
          'password': 'defaultpassword', // Password is hidden in the UI but required in the backend
        }),
      );

      if (response.statusCode == 200 && mounted) {
        fetchSales();
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                message: 'Data berhasil ditambahkan!',
                onClose: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            },
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan!')),
        );
      }
    }
  }

  Future<void> updateSales(String id) async {
    final String apiUrl = 'https://backend-sales-pearl.vercel.app/api/owner/sales/$id';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'nama': _namaController.text,
          'noHP': _noHPController.text,
          'alamat': _alamatController.text,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        fetchSales();
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                message: 'Data berhasil diperbarui!',
                onClose: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            },
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan!')),
        );
      }
    }
  }

  Future<void> deleteSales(String id) async {
    final String apiUrl = 'https://backend-sales-pearl.vercel.app/api/owner/sales/$id';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        fetchSales();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil dihapus!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan!')),
        );
      }
    }
  }

  void _showAddOrEditSalesForm([String? id]) {
    if (id != null) {
      final sales = _salesList.firstWhere((element) => element['sales']['_id'] == id)['sales'];
      _usernameController.text = sales['username'];
      _namaController.text = sales['nama'];
      _noHPController.text = sales['noHP'];
      _alamatController.text = sales['alamat'];
      _currentEditId = id;
    } else {
      _usernameController.clear();
      _namaController.clear();
      _noHPController.clear();
      _alamatController.clear();
      _currentEditId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _currentEditId == null ? 'Tambah Data Sales' : 'Edit Data Sales',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(_usernameController, 'Username', Icons.person),
                SizedBox(height: 10),
                _buildTextField(_namaController, 'Nama', Icons.account_box),
                SizedBox(height: 10),
                _buildTextField(_noHPController, 'No HP', Icons.phone),
                SizedBox(height: 10),
                _buildTextField(_alamatController, 'Alamat', Icons.location_on),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentEditId == null) {
                        addSales();
                      } else {
                        updateSales(_currentEditId!);
                      }
                    },
                    child: Text(_currentEditId == null ? 'Tambah Data' : 'Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

   String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sales'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddOrEditSalesForm(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _salesList.length,
              itemBuilder: (context, index) {
                final sales = _salesList[index]['sales'];
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(sales['username'][0].toUpperCase()),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    title: Text(sales['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Username: ${sales['username']}'),
                        Text('No HP: ${sales['noHP']}'),
                        Text('Alamat: ${sales['alamat']}'),
                        Text('Created At: ${formatDateTime(sales['createdAt'] ?? '')}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showAddOrEditSalesForm(sales['_id']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Konfirmasi Hapus'),
                                  content: Text('Apakah Anda yakin ingin menghapus data ini?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteSales(sales['_id']);
                                      },
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
