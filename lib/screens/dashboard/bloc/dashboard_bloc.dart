import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:meta/meta.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    var data;
    on<DashboardEvent>((event, emit) async {
      if (event is DashboardLoad) {
        var res = await ApiClient.getUnAuth('api/admin/dashboard');
        log(res.toString());
        if (res['success']) {
          data = res['data'];
          log(data.toString());
        }
        emit(DashboardLoaded(data: data));
      }
    });
  }
}
