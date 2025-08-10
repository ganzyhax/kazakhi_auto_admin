part of 'shipments_bloc.dart';

@immutable
sealed class ShipmentsState {}

final class ShipmentsInitial extends ShipmentsState {}

final class ShipmentsLoaded extends ShipmentsState {
  final data;
  final shipment;
  ShipmentsLoaded({required this.data, required this.shipment});
}
