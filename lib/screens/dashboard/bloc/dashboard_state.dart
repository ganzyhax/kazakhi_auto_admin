part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final data;
  DashboardLoaded({required this.data});
}
