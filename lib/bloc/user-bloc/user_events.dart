import 'package:equatable/equatable.dart';

abstract class UserEvents extends Equatable {
  const UserEvents();

  @override
  List<Object?> get props => [];
}

class FetchUsersEvent extends UserEvents {
  final int? page;
  final int? limit;
  final String? searchValue;

  const FetchUsersEvent({this.page, this.limit, this.searchValue});

  @override
  List<Object?> get props => [page, limit, searchValue];
}
