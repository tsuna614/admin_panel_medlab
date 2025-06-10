import 'package:admin_panel_medlab/bloc/user-bloc/user_events.dart';
import 'package:admin_panel_medlab/bloc/user-bloc/user_states.dart';
import 'package:admin_panel_medlab/services/user_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvents, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(UserInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final response = await userService.fetchUsers(
      event.page,
      event.limit,
      event.searchValue,
    );

    if (response.statusCode == 200 && response.data != null) {
      final userResponse = response.data!;

      emit(
        UserLoaded(
          users: userResponse.users,
          currentPage: userResponse.currentPage,
          totalUsers: userResponse.total,
          currentSearchValue: event.searchValue,
        ),
      );
    } else {
      emit(
        UserError(
          message: response.errorMessage ?? "Unknown error fetching users.",
        ),
      );
    }
  }
}
