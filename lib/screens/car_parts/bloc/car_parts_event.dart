part of 'car_parts_bloc.dart';

@immutable
sealed class CarPartsEvent {}

final class CarPartsLoad extends CarPartsEvent {}
