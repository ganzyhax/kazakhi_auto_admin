part of 'users_bloc.dart';

@immutable
sealed class UsersEvent {}

class UserLoad extends UsersEvent {
  final int page;
  UserLoad({required this.page});
}
