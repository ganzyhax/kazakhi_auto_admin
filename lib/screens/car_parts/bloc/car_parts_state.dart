part of 'car_parts_bloc.dart';

@immutable
sealed class CarPartsState {}

final class CarPartsInitial extends CarPartsState {}

final class CarPartsLoaded extends CarPartsState {
  final data;

  CarPartsLoaded({required this.data});
}
