// screens/users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kazakhi_auto_admin/screens/models/user_model.dart';
import 'package:kazakhi_auto_admin/screens/users/bloc/users_bloc.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersBloc()..add(UserLoad(page: 1)),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              if (state is UsersLoaded) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Управление пользователями',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 2,
                        width: 150,
                        color: Colors.indigo[200],
                      ),
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
                              Text(
                                'Все пользователи',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
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
                                      (state.users as List<dynamic>).map<
                                        DataRow
                                      >((user) {
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),

                                            DataCell(Text(user['email'])),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  (user['isVerified'])
                                                      ? 'Aктивный'
                                                      : 'Неактивный',
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
                                            DataCell(
                                              Text(
                                                user['reports'].length
                                                    .toString(),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                user['shipments'].length
                                                    .toString(),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(state.totalPages, (
                                  index,
                                ) {
                                  final pageNum = index + 1;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<UsersBloc>().add(
                                          UserLoad(page: pageNum),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            pageNum == state.currentPage
                                                ? Colors.indigo
                                                : Colors.grey[200],
                                        foregroundColor:
                                            pageNum == state.currentPage
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      child: Text('$pageNum'),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
