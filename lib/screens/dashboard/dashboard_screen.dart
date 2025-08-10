// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazakhi_auto_admin/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:kazakhi_auto_admin/screens/models/shipment_model.dart';
import 'package:kazakhi_auto_admin/screens/models/user_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(DashboardLoad()),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Панель',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 2, width: 150, color: Colors.indigo[200]),
                  const SizedBox(height: 32),

                  // Metric Containers
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine number of columns based on screen width
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 700) {
                        crossAxisCount = 2;
                      }
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 32.0,
                        mainAxisSpacing: 32.0,
                        childAspectRatio:
                            2.5, // Adjust aspect ratio for better card sizing
                        children: [
                          _buildMetricCard(
                            context,
                            'Общее количество пользователей',
                            state.data['totalUsers'].toString(),
                            Colors.indigo,
                            Icons.people_alt_rounded,
                          ),
                          _buildMetricCard(
                            context,
                            'Общее количество заказов',
                            state.data['totalOrders'].toString(),
                            Colors.green,
                            Icons.shopping_cart_rounded,
                          ),
                          _buildMetricCard(
                            context,
                            'Общее количество отправок',
                            state.data['totalShipments'].toString(),
                            Colors.orange,
                            Icons.local_shipping_rounded,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Users Table
                  _buildSectionTitle('Пользователи'),
                  const SizedBox(height: 24),
                  _buildUsersTable(context, state.data['latestUsers']),
                  const SizedBox(height: 48),

                  // Shipments Table
                  _buildSectionTitle('Контейнеры'),
                  const SizedBox(height: 24),
                  _buildShipmentsTable(context, state.data['latestShipments']),
                  const SizedBox(height: 32),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          // Handle card tap, e.g., navigate to a detailed view
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Icon(icon, size: 64, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(height: 1.5, width: 100, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildUsersTable(BuildContext context, users) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.grey[50]!,
            ),
            dataRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.white,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            columnSpacing: 40,
            horizontalMargin: 12,
            columns: const [
              DataColumn(
                label: Text(
                  'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Cтатус',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Отчеты',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Контайнеры',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            rows:
                (users as List<dynamic>).map<DataRow>((user) {
                  Color statusColor;
                  Color statusBgColor;
                  switch (user['isVerified']) {
                    case true:
                      statusColor = Colors.green[800]!;
                      statusBgColor = Colors.green[100]!;
                      break;
                    case false:
                      statusColor = Colors.red[800]!;
                      statusBgColor = Colors.red[100]!;
                      break;

                    default:
                      statusColor = Colors.grey[800]!;
                      statusBgColor = Colors.grey[100]!;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '1111',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      DataCell(Text(user['email'])),
                      DataCell(
                        Chip(
                          label: Text(
                            (user['isVerified']) ? 'Aктивный' : 'Неактивный',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: statusBgColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      DataCell(Text(user['reports'].length.toString())),
                      DataCell(Text(user['shipments'].length.toString())),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentsTable(BuildContext context, shipments) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.grey[50]!,
            ),
            dataRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.white,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            columnSpacing: 40,
            horizontalMargin: 12,
            columns: const [
              DataColumn(
                label: Text(
                  'Номер контайнера',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Машина',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'VIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Заказчик',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Порт прибытия',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  'Оплачено',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              DataColumn(
                label: Text(
                  'Остаток',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Статус',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Создан',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            rows:
                (shipments as List<dynamic>).map<DataRow>((shipment) {
                  Color statusColor;
                  Color statusBgColor;
                  switch (shipment['status']) {
                    case 'delivered':
                      statusColor = Colors.blue[800]!;
                      statusBgColor = Colors.blue[100]!;
                      break;
                    case 'in_transit':
                      statusColor = Colors.purple[800]!;
                      statusBgColor = Colors.purple[100]!;
                      break;
                    case 'pending':
                      statusColor = Colors.yellow[800]!;
                      statusBgColor = Colors.yellow[100]!;
                      break;
                    default:
                      statusColor = Colors.grey[800]!;
                      statusBgColor = Colors.grey[100]!;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          shipment['containerNumber'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          shipment['user']['email'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          shipment['carInfo']['brand'] +
                              ' ' +
                              shipment['carInfo']['model'] +
                              ' ' +
                              shipment['carInfo']['year'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          shipment['carInfo']['vin'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      DataCell(
                        Text(
                          shipment['receivingPort'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          shipment['paid'].toString() + '\$',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          shipment['balance'].toString() + '\$',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),

                      DataCell(
                        Chip(
                          label: Text(
                            shipment['status'],
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: statusBgColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      DataCell(Text(shipment['createdAt'].toString())),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
