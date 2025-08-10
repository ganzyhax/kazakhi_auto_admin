import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:meta/meta.dart';

part 'shipments_event.dart';
part 'shipments_state.dart';

class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  ShipmentsBloc() : super(ShipmentsInitial()) {
    var shipment;
    var data;
    on<ShipmentsEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is ShipmentsLoad) {
        var res = await ApiClient.get('api/shipments/');
        if (res['success']) {
          data = res['data'];
          log(data.toString());
          emit(ShipmentsLoaded(data: data, shipment: shipment));
        }
      }
      if (event is ShipmentsGetById) {
        var res = await ApiClient.get('api/shipments/${event.id}');
        if (res['success']) {
          shipment = res['data'];
        } else {
          shipment = null;
        }
        emit(ShipmentsLoaded(data: data, shipment: shipment));
      }
    });
  }
}
