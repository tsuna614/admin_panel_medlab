import 'package:admin_panel_medlab/models/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final int currentPage;
  final int totalUsers;
  final int rowsPerPage = 10;
  final String? currentSearchValue;

  const UserLoaded({
    required this.users,
    required this.currentPage,
    required this.totalUsers,
    this.currentSearchValue,
  });

  @override
  List<Object?> get props => [
    users,
    currentPage,
    totalUsers,
    currentSearchValue,
  ];
}

class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
