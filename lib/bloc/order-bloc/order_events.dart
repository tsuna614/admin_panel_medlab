import 'package:equatable/equatable.dart';

abstract class OrderEvents extends Equatable {
  const OrderEvents();

  @override
  List<Object?> get props => [];
}

class FetchOrdersEvent extends OrderEvents {
  final int page;
  final int limit;
  final String? statusFilter;

  const FetchOrdersEvent({
    required this.page,
    required this.limit,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [page, limit, statusFilter];
}

class ChangeOrderStatusEvent extends OrderEvents {
  final String orderId;
  final String status;

  const ChangeOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class DeleteOrderEvent extends OrderEvents {
  final String orderId;

  const DeleteOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
