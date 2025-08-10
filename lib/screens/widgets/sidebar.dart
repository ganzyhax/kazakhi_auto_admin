// widgets/sidebar.dart
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String activePage;
  final ValueChanged<String> onNavigate;

  const Sidebar({
    super.key,
    required this.activePage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10, // Shadow for the sidebar
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        width: 250, // Fixed width for the sidebar
        color: Colors.grey[850], // Dark background for the sidebar
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Panel Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Админ Панель',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[300],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Navigation Items
            _buildNavItem(
              context,
              'Главная',
              'dashboard',
              Icons.dashboard_rounded,
            ),
            _buildNavItem(
              context,
              'Пользователи',
              'users',
              Icons.people_alt_rounded,
            ),
            _buildNavItem(
              context,
              'Заказы',
              'orders',
              Icons.shopping_cart_rounded,
            ),
            _buildNavItem(
              context,
              'Контейнеры',
              'shipments',
              Icons.local_shipping_rounded,
            ),
            const Spacer(), // Pushes copyright to the bottom
            // Copyright
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                '© 2025 KAG',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    String page,
    IconData icon,
  ) {
    final bool isSelected = activePage == page;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: isSelected ? Colors.indigo[600] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onNavigate(page),
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.grey[700],
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[300],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
