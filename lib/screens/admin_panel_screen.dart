import 'package:flutter/material.dart';
import 'package:kazakhi_auto_admin/screens/car_parts/car_parts_requests_screen.dart';
import 'package:kazakhi_auto_admin/screens/dashboard/dashboard_screen.dart';
import 'package:kazakhi_auto_admin/screens/information/information_edit_screen.dart';
import 'package:kazakhi_auto_admin/screens/information/information_screen.dart';
import 'package:kazakhi_auto_admin/screens/orders/orders_screen.dart';
import 'package:kazakhi_auto_admin/screens/shipments/shipments_screen.dart';
import 'package:kazakhi_auto_admin/screens/users/users_screen.dart';
import 'package:kazakhi_auto_admin/screens/widgets/sidebar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _activePage = 'dashboard';

  // Map page names to their corresponding widgets
  Widget _getPageWidget() {
    switch (_activePage) {
      case 'dashboard':
        return const DashboardScreen();
      case 'users':
        return const UsersScreen();
      case 'orders':
        return const OrdersScreen();
      case 'shipments':
        return const ShipmentsScreen();
      case 'information':
        return ContentListPage(); // Assuming DropContentPage is defined elsewhere
      case 'car_parts_requests':
        return const CarPartsRequestPage();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            activePage: _activePage,
            onNavigate: (page) {
              setState(() {
                _activePage = page;
              });
            },
          ),
          // Main content area
          Expanded(child: _getPageWidget()),
        ],
      ),
    );
  }
}
