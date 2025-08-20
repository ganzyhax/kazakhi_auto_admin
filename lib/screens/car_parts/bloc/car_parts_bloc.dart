import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:meta/meta.dart';

part 'car_parts_event.dart';
part 'car_parts_state.dart';

class CarPartsBloc extends Bloc<CarPartsEvent, CarPartsState> {
  CarPartsBloc() : super(CarPartsInitial()) {
    var data;
    on<CarPartsEvent>((event, emit) async {
      if (event is CarPartsLoad) {
        var res = await ApiClient.get('api/carparts');
        if (res['success']) {
          data = res['data']['data'];
          log(data.toString() + '11111');
        }
        emit(CarPartsLoaded(data: data));
      }

      // TODO: implement event handler
    });
  }
}
