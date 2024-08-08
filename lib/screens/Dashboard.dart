
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sales/screens/items_page.dart';
import 'package:sales/screens/sales_page.dart';
import 'package:sales/screens/stock_history.dart';


class NextPage extends StatelessWidget {
  const NextPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Owner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildDashboardCard(
                    icon: Icons.account_circle,
                    title: 'Sales',
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SalesPage()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Transaksi',
                    onTap: () {
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
                      Navigator.push(context,
                       MaterialPageRoute(builder: (context) => StockPage())
                       );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}