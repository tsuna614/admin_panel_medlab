import 'package:admin_panel_medlab/bloc/order-bloc/order_events.dart';
import 'package:admin_panel_medlab/bloc/order-bloc/order_states.dart';
import 'package:admin_panel_medlab/services/order_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderBloc extends Bloc<OrderEvents, OrderState> {
  final OrderService orderService;

  OrderBloc({required this.orderService}) : super(OrderInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
    on<ChangeOrderStatusEvent>(_onChangeOrderStatus);
    on<DeleteOrderEvent>(_onDeleteOrder);
  }

  Future<void> _onFetchOrders(
    FetchOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    final bool isInitialLoadOrFilterChange =
        (state is OrderInitial) ||
        (state is OrdersLoaded &&
            (state as OrdersLoaded).currentStatusFilter !=
                event.statusFilter) ||
        (state is OrdersLoaded &&
            (state as OrdersLoaded).orders.isEmpty &&
            event.page == 0);

    if (isInitialLoadOrFilterChange) {
      emit(
        OrderLoading(),
      ); // Show full loading indicator for new filter/initial
    }

    final response = await orderService.fetchOrders(
      event.page,
      event.limit,
      event.statusFilter,
    );

    if (response.statusCode == 200 && response.data != null) {
      final orderResponse = response.data!;

      emit(
        OrdersLoaded(
          orders: orderResponse.orders,
          currentPage: orderResponse.currentPage,
          totalOrders: orderResponse.total,
          currentStatusFilter: event.statusFilter,
        ),
      );
    } else {
      emit(
        OrderError(response.errorMessage ?? "Unknown error fetching orders."),
      );
    }
  }

  Future<void> _onChangeOrderStatus(
    ChangeOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrderLoading()); // Show loading indicator while changing status

      final response = await orderService.changeOrderStatus(
        orderId: event.orderId,
        status: event.status,
      );

      if (response.statusCode == 200) {
        emit(OrderUpdateSuccess(message: "Order status updated successfully."));
        add(
          FetchOrdersEvent(
            page: currentState.currentPage,
            limit: currentState.rowsPerPage,
            statusFilter: currentState.currentStatusFilter,
          ),
        );
      } else {
        emit(
          OrderError(response.errorMessage ?? "Error changing order status."),
        );
      }
    } else {
      emit(OrderError("Cannot change order status, orders not loaded."));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(OrderLoading()); // Show loading indicator while deleting

      final response = await orderService.deleteOrder(event.orderId);

      if (response.statusCode == 200) {
        emit(OrderUpdateSuccess(message: "Order deleted successfully."));
        // Optionally, you can trigger a fetch to refresh the order list
        add(
          FetchOrdersEvent(
            page: currentState.currentPage,
            limit: currentState.rowsPerPage,
            statusFilter: currentState.currentStatusFilter,
          ),
        );
      } else {
        emit(OrderError(response.errorMessage ?? "Error deleting order."));
      }
    } else {
      emit(OrderError("Cannot delete order, orders not loaded."));
    }
  }
}
