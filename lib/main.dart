// main.dart
import 'package:flutter/material.dart';
import 'package:kazakhi_auto_admin/screens/admin_panel_screen.dart';

import 'package:kazakhi_auto_admin/screens/dashboard/dashboard_screen.dart';
import 'package:kazakhi_auto_admin/screens/orders/orders_screen.dart';
import 'package:kazakhi_auto_admin/screens/shipments/shipments_screen.dart';
import 'package:kazakhi_auto_admin/screens/users/users_screen.dart';
import 'package:kazakhi_auto_admin/screens/widgets/sidebar.dart'; // Import the sidebar
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru', null); // инициализация локали

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Assuming Inter font is imported or available
        scaffoldBackgroundColor:
            Colors.grey[100], // Background color for the main content area
      ),
      home: const AdminHomePage(),
    );
  }
}
