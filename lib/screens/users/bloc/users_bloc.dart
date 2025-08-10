import 'package:bloc/bloc.dart';
import 'package:kazakhi_auto_admin/api/api.dart';
import 'package:meta/meta.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {
    var users;
    on<UsersEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is UserLoad) {
        final page = event.page; // добавить page в UserLoad
        var res = await ApiClient.get('api/admin/users?page=$page&limit=5');
        if (res['success']) {
          users = res['data']['users'];
          emit(
            UsersLoaded(
              users: users,
              currentPage: res['data']['currentPage'],
              totalPages: res['data']['totalPages'],
            ),
          );
        }
      }
    });
  }
}
