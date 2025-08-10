part of 'users_bloc.dart';

@immutable
sealed class UsersState {}

final class UsersInitial extends UsersState {}

class UsersLoaded extends UsersState {
  final users;
  final int currentPage;
  final int totalPages;

  UsersLoaded({
    required this.users,
    required this.currentPage,
    required this.totalPages,
  });
}
