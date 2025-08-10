part of 'shipments_bloc.dart';

@immutable
sealed class ShipmentsEvent {}

class ShipmentsLoad extends ShipmentsEvent {}

class ShipmentsGetById extends ShipmentsEvent {
  final String id;
  ShipmentsGetById({required this.id});
}
