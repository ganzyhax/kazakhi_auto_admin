import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kazakhi_auto_admin/screens/car_parts/bloc/car_parts_bloc.dart';

class CarPartsRequestPage extends StatelessWidget {
  const CarPartsRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => CarPartsBloc()..add(CarPartsLoad()),
        child: BlocBuilder<CarPartsBloc, CarPartsState>(
          builder: (context, state) {
            if (state is CarPartsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Page Title
                      const Text(
                        'Запросы на запчасти',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Decorative Divider
                      Container(
                        height: 2,
                        width: 150,
                        color: Colors.indigo[200],
                      ),
                      const SizedBox(height: 32),

                      // Main Content Card
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
                              const Text(
                                'Все запросы',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1.5,
                                width: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 24),

                              // Data Table for Requests
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                        (states) => Colors.grey[50]!,
                                      ),
                                  dataRowColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.white,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  columnSpacing: 30,
                                  horizontalMargin: 12,
                                  columns: const [
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
                                        'Телефон',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Комментарий',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Дата',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      state.data.map<DataRow>((request) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(request['email'])),
                                            DataCell(Text(request['phone'])),
                                            DataCell(
                                              SizedBox(
                                                width:
                                                    600, // Constrain width for long comments
                                                child: Text(
                                                  request['comment'],
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                request['createdAt'] != null
                                                    ? DateFormat(
                                                      'dd-MM-yyyy',
                                                    ).format(
                                                      DateTime.parse(
                                                        request['createdAt'],
                                                      ),
                                                    )
                                                    : '-',
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
                    ],
                  ),
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
