import 'package:admin_panel_medlab/view/doctor/doctor_screen.dart';
import 'package:admin_panel_medlab/view/order/order_screen.dart';
import 'package:admin_panel_medlab/view/product/product_screen.dart';
import 'package:admin_panel_medlab/view/user/user_screen.dart';
import 'package:admin_panel_medlab/view/voucher/voucher_screen.dart';
import 'package:flutter/material.dart';

class NavigatingScreen extends StatefulWidget {
  const NavigatingScreen({super.key});

  @override
  State<NavigatingScreen> createState() => _NavigatingScreenState();
}

class _NavigatingScreenState extends State<NavigatingScreen> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    UserScreen(),
    ProductScreen(),
    OrderScreen(),
    DoctorScreen(),
    VoucherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel MedLab')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Vouchers',
          ),
        ],
      ),
      body: Center(child: _pages[_currentPageIndex]),
    );
  }
}
