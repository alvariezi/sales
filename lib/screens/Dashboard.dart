
// ignore_for_file: unused_import, file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales/screens/items_page.dart';
import 'package:sales/screens/sales_page.dart';
import 'package:sales/screens/stock_history.dart';
import 'package:sales/screens/login_page.dart'; 

class DashboardPage extends StatelessWidget {
  final String token;

  const DashboardPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Owner'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.account_circle,
                      title: 'Sales',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SalesPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Transaksi',
                      onTap: () {
                        // Implement navigation or action
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.storefront_outlined,
                      title: 'Produk',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ItemsPage()),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.monetization_on_outlined,
                      title: 'Riwayat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StockPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _logout(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffF4F4F4),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.blue.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
