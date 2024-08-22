import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
  final TextEditingController _passwordController = TextEditingController();

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
          'password': _passwordController.text,
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
      _passwordController.clear();
      _currentEditId = id;
    } else {
      _usernameController.clear();
      _namaController.clear();
      _noHPController.clear();
      _alamatController.clear();
      _passwordController.clear();
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
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                _buildTextField(_noHPController, 'No HP', Icons.phone, isNumeric: true),
                SizedBox(height: 10),
                _buildTextField(_alamatController, 'Alamat', Icons.location_on),
                SizedBox(height: 10),
                if (_currentEditId == null)
                  Column(
                    children: [
                      _buildTextField(_passwordController, 'Password', Icons.lock),
                      SizedBox(height: 20),
                    ],
                  ),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteSales(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSalesDetailDialog(Map<String, dynamic> sales) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Detail Sales',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              _buildDetailRow(Icons.person, 'Username:', sales['username']),
              _buildDetailRow(Icons.account_box, 'Nama:', sales['nama']),
              _buildDetailRow(Icons.phone, 'No HP:', sales['noHP']),
              _buildDetailRow(Icons.location_on, 'Alamat:', sales['alamat']),
              _buildDetailRow(Icons.calendar_today, 'Dibuat:', formatDateTime(sales['createdAt'] ?? '')),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.blueAccent),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


   String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    String timeZone = "WIB";
    return '$formattedDate $timeZone';
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5, 
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                  title: Container(
                    height: 10,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 10,
                    color: Colors.white,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 8),
                      Icon(Icons.delete, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sales'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? _buildShimmer()
          : ListView.builder(
  itemCount: _salesList.length,
  itemBuilder: (BuildContext context, int index) {
    final sales = _salesList[index]['sales'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
      child: Card(
        color: Color(0xffF4F4F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        margin: EdgeInsets.zero, 
        child: Padding(
          padding: EdgeInsets.all(16), 
          child: ListTile(
            onTap: () => _showSalesDetailDialog(sales),
            leading: CircleAvatar(
              child: Text(sales['nama'][0].toUpperCase()),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            title: Text(sales['username']),
            subtitle: Text(sales['nama']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showAddOrEditSalesForm(sales['_id']),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(sales['_id']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
)
,      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditSalesForm(),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
