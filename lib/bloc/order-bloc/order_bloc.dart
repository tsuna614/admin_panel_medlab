import 'package:admin_panel_medlab/bloc/order-bloc/order_events.dart';
import 'package:admin_panel_medlab/bloc/order-bloc/order_states.dart';
import 'package:admin_panel_medlab/services/order_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderBloc extends Bloc<OrderEvents, OrderState> {
  final OrderService orderService;

  OrderBloc({required this.orderService}) : super(OrderInitial()) {
    on<FetchOrdersEvent>(_onFetchOrders);
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
}
