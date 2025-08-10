// screens/shipments_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:kazakhi_auto_admin/screens/models/shipment_model.dart';
import 'package:kazakhi_auto_admin/screens/shipments/bloc/shipments_bloc.dart';
import 'package:kazakhi_auto_admin/screens/shipments/compenents/shipment_create_modal.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});
  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final day = DateFormat('d', 'ru').format(date);
    final month = DateFormat('MMM', 'ru').format(date); // 'май'
    final time = DateFormat('HH:mm').format(date);

    return '$day $month $time';
  }

  String getStatusText(String status) {
    switch (status) {
      case 'purchased':
        return 'Куплен';
      case 'in_transit':
        return 'В пути';
      case 'arrived':
        return 'Прибыл';
      case 'delivered':
        return 'Доставлен';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShipmentsBloc()..add(ShipmentsLoad()),
      child: BlocBuilder<ShipmentsBloc, ShipmentsState>(
        builder: (context, state) {
          if (state is ShipmentsLoaded) {
            return Align(
              alignment: Alignment.topLeft,

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Управление отправками',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 2, width: 150, color: Colors.indigo[200]),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.grey.withOpacity(0.2),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Все контейнеры',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (_) => const Dialog(
                                            insetPadding: EdgeInsets.all(20),
                                            child: ShipmentCreateModal(),
                                          ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Добавить контайнер',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1.5,
                              width: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 24),
                            SingleChildScrollView(
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
                                      'Заказчик',
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
                                  DataColumn(
                                    label: Text(
                                      'Действия',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                                rows:
                                    (state.data as List<dynamic>).map<DataRow>((
                                      shipment,
                                    ) {
                                      final formatted = formatDate(
                                        shipment['createdAt'],
                                      );

                                      Color statusColor;
                                      Color statusBgColor;
                                      switch (shipment['status']) {
                                        case 'purchased':
                                          statusColor = Colors.blue[800]!;
                                          statusBgColor = Colors.blue[100]!;
                                          break;
                                        case 'in_transit':
                                          statusColor = Colors.purple[800]!;
                                          statusBgColor = Colors.purple[100]!;
                                          break;
                                        case 'arrived':
                                          statusColor = Colors.yellow[800]!;
                                          statusBgColor = Colors.yellow[100]!;
                                          break;
                                        case 'delivered':
                                          statusColor =
                                              const Color.fromARGB(
                                                255,
                                                112,
                                                255,
                                                68,
                                              )!;
                                          statusBgColor =
                                              const Color.fromARGB(
                                                255,
                                                240,
                                                255,
                                                236,
                                              )!;
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              shipment['user']['email'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              shipment['carInfo']['brand'] +
                                                  ' ' +
                                                  shipment['carInfo']['model'] +
                                                  ' ' +
                                                  shipment['carInfo']['year']
                                                      .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              shipment['carInfo']['vin'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          DataCell(
                                            Text(
                                              shipment['receivingPort'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              shipment['paid'].toString() +
                                                  '\$',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              shipment['balance'].toString() +
                                                  '\$',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),

                                          DataCell(
                                            Chip(
                                              label: Text(
                                                getStatusText(
                                                  shipment['status'],
                                                ),

                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor: statusBgColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(formatted)),
                                          DataCell(
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    var res =
                                                        await ApiClient.get(
                                                          'api/shipments/' +
                                                              shipment['_id'],
                                                        );
                                                    log(res.toString());
                                                    if (res['success']) {
                                                      final bloc =
                                                          BlocProvider.of<
                                                            ShipmentsBloc
                                                          >(context);

                                                      await showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder:
                                                            (
                                                              _,
                                                            ) => BlocProvider.value(
                                                              value: bloc,
                                                              child: Dialog(
                                                                insetPadding:
                                                                    const EdgeInsets.all(
                                                                      20,
                                                                    ),
                                                                child: ShipmentCreateModal(
                                                                  shipmentData:
                                                                      res['data'],
                                                                ),
                                                              ),
                                                            ),
                                                      );
                                                      bloc.add(
                                                        ShipmentsLoad(),
                                                      ); // ✅ Загрузка после закрытия
                                                    }
                                                  },
                                                  child: Icon(Icons.edit),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red[600],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
