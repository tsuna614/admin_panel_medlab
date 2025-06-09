import 'package:admin_panel_medlab/models/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalOrders;
  final int rowsPerPage = 10; // Default value, can be adjusted
  final String? currentStatusFilter;
  final String? currentSortBy;
  final String? currentSortOrder;

  const OrdersLoaded({
    required this.orders,
    this.currentPage = 1,
    this.totalOrders = 0,
    this.currentStatusFilter,
    this.currentSortBy,
    this.currentSortOrder,
  });

  OrdersLoaded copyWith({
    List<Order>? orders,
    int? currentPage,
    int? totalOrders,
    String? currentStatusFilter,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      totalOrders: totalOrders ?? this.totalOrders,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    currentPage,
    totalOrders,
    currentStatusFilter,
    currentSortBy,
    currentSortOrder,
  ];
}

class OrderUpdateSuccess extends OrderState {
  final String message;

  const OrderUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class OrderDeleteSuccess extends OrderState {
  final String message;

  const OrderDeleteSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
