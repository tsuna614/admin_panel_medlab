// ignore_for_file: constant_identifier_names

import 'package:admin_panel_medlab/bloc/order-bloc/order_bloc.dart';
import 'package:admin_panel_medlab/bloc/order-bloc/order_events.dart';
import 'package:admin_panel_medlab/bloc/order-bloc/order_states.dart';
import 'package:admin_panel_medlab/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your Order BLoC, Events, States, and Order Model

// --- Placeholder BLoC and Models for OrderScreen ---
// Replace with your actual implementations
// (Order model is defined above)

// Assuming your OrderStatus enum is defined in Dart as well
// enum OrderAppStatus { Pending, Processing, Shipped, Delivered, Cancelled, Refunded }

enum AppOrderStatus {
  // Example Dart enum
  Pending,
  Processing,
  Shipped,
  Delivered,
  Cancelled,
  Refunded,
  All,
}

extension AppOrderStatusExtension on AppOrderStatus {
  String get displayName {
    if (this == AppOrderStatus.All) return "All Statuses";
    return name; // Uses the enum case name directly (e.g., "Pending")
  }

  // Optional: For sending to API if API expects exact string from your Mongoose enum
  String? get apiValue {
    if (this == AppOrderStatus.All)
      return null; // API expects null or no param for all
    return name; // e.g. "Pending", "Processing"
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    // Example of providing filters if your BLoC and Service support them
    // You'd have UI elements (Dropdowns) to set these filters and re-trigger fetch
    AppOrderStatus _selectedStatusFilter =
        AppOrderStatus.All; // Default to show all orders

    // String? currentSortBy = "createdAt"; // Default sort
    // String? currentSortOrder = "desc";

    void _applyFilters() {
      // When filters change, fetch page 0 with new filters
      context.read<OrderBloc>().add(
        FetchOrdersEvent(
          page: 0,
          limit: (context.read<OrderBloc>().state is OrdersLoaded)
              ? (context.read<OrderBloc>().state as OrdersLoaded).rowsPerPage
              : PaginatedDataTable
                    .defaultRowsPerPage, // Get current rowsPerPage
          statusFilter: _selectedStatusFilter.apiValue,
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<AppOrderStatus>(
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
              value: _selectedStatusFilter,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              isExpanded: true,
              items: AppOrderStatus.values.map((AppOrderStatus status) {
                // Use your Dart enum
                return DropdownMenuItem<AppOrderStatus>(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (AppOrderStatus? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatusFilter = newValue;
                  });
                  _applyFilters(); // Re-fetch data with the new filter
                }
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              // Use BlocConsumer for messages
              listener: (context, state) {
                if (state is OrderUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is OrderDeleteSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is OrderError && state is! OrdersLoaded) {
                  // Avoid showing error snackbar if data is already loaded
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrderInitial ||
                    (state is OrderLoading && state is! OrdersLoaded)) {
                  if (state is OrderInitial) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        context.read<OrderBloc>().add(
                          FetchOrdersEvent(
                            page: 0,
                            limit: PaginatedDataTable.defaultRowsPerPage,
                            // statusFilter: currentStatusFilter,
                            // sortBy: currentSortBy,
                            // sortOrder: currentSortOrder,
                          ),
                        );
                      }
                    });
                  }
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OrdersLoaded) {
                  return SizedBox(
                    width: double.infinity,
                    child: OrderDataTable(
                      orders: state.orders,
                      totalOrders: state.totalOrders,
                      rowsPerPage: state.rowsPerPage, // Get from state
                      currentPageZeroIndexed:
                          state.currentPage - 1, // Get from state
                      // Pass filter/sort state if DataTable needs to redispatch with them
                      currentStatusFilter: state.currentStatusFilter,
                      currentSortBy: state.currentSortBy,
                      currentSortOrder: state.currentSortOrder,
                    ),
                  );
                } else if (state is OrderError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () => context.read<OrderBloc>().add(
                            FetchOrdersEvent(
                              page: 0,
                              limit: PaginatedDataTable.defaultRowsPerPage,
                              // statusFilter: currentStatusFilter,
                              // sortBy: currentSortBy,
                              // sortOrder: currentSortOrder,
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text('Something went wrong with orders.'),
                );
              },
            ),
          ),
        ],
      ),
      // No FAB for creating orders, as admin typically doesn't create them manually this way
    );
  }
}

class OrderDataTable extends StatefulWidget {
  final List<Order> orders;
  final int totalOrders;
  final int rowsPerPage;
  final int currentPageZeroIndexed;
  // Filters/Sort state passed from BLoC to re-apply on page/rows change
  final String? currentStatusFilter;
  final String? currentSortBy;
  final String? currentSortOrder;

  const OrderDataTable({
    super.key,
    required this.orders,
    required this.totalOrders,
    required this.rowsPerPage,
    required this.currentPageZeroIndexed,
    this.currentStatusFilter,
    this.currentSortBy,
    this.currentSortOrder,
  });

  @override
  State<OrderDataTable> createState() => _OrderDataTableState();
}

class _OrderDataTableState extends State<OrderDataTable> {
  OrderDataSource? _dataSource;
  int _sortColumnIndex = 1; // Default sort by date
  bool _sortAscending = false; // Default descending (newest first)

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  @override
  void didUpdateWidget(covariant OrderDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.orders != oldWidget.orders ||
        widget.totalOrders != oldWidget.totalOrders ||
        widget.rowsPerPage != oldWidget.rowsPerPage ||
        widget.currentPageZeroIndexed != oldWidget.currentPageZeroIndexed) {
      _updateDataSource();
    }
  }

  void _updateDataSource() {
    if (mounted) {
      _dataSource = OrderDataSource(
        ordersCurrentlyDisplaying: List.from(
          widget.orders,
        ), // Use a copy for local sort
        context: context,
      );
      _dataSource?.updateTotalRowCount(widget.totalOrders);
    }
  }

  void _sort<T>(
    Comparable<T> Function(Order o) getField,
    int columnIndex,
    bool ascending,
  ) {
    // Client-side sort example. For server-side, dispatch event to BLoC
    _dataSource?.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderBloc = BlocProvider.of<OrderBloc>(context);
    if (_dataSource == null) {
      return const Center(child: Text("Loading order data..."));
    }

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: const Text('Orders'),
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [10, 25, 50],
        initialFirstRowIndex:
            widget.currentPageZeroIndexed * widget.rowsPerPage,
        onRowsPerPageChanged: (value) {
          if (value != null && value != widget.rowsPerPage) {
            orderBloc.add(
              FetchOrdersEvent(
                page: 0,
                limit: value,
                // statusFilter: widget.currentStatusFilter,
                // sortBy: widget.currentSortBy,
                // sortOrder: widget.currentSortOrder,
              ),
            );
          }
        },
        onPageChanged: (firstRowIndex) {
          int newPage = (firstRowIndex / widget.rowsPerPage).floor() + 1;
          if (newPage != widget.currentPageZeroIndexed + 1) {
            orderBloc.add(
              FetchOrdersEvent(
                page: newPage,
                limit: widget.rowsPerPage,
                // statusFilter: widget.currentStatusFilter,
                // sortBy: widget.currentSortBy,
                // sortOrder: widget.currentSortOrder,
              ),
            );
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          const DataColumn(label: Text('Order #')),
          DataColumn(
            label: const Text('Date'),
            onSort: (ci, asc) =>
                _sort<DateTime>((o) => DateTime.parse(o.createdAt), ci, asc),
          ), // Assuming createdAt is sortable string
          const DataColumn(label: Text('Customer (User ID)')),
          DataColumn(
            label: const Text('Total'),
            numeric: true,
            onSort: (ci, asc) => _sort<num>((o) => 10, ci, asc),
          ),
          DataColumn(
            label: const Text('Status'),
            onSort: (ci, asc) =>
                _sort<String>((o) => o.status.toString(), ci, asc),
          ),
          const DataColumn(label: Text('Actions')),
        ],
        source: _dataSource!,
      ),
    );
  }
}

class OrderDataSource extends DataTableSource {
  final BuildContext context;
  final List<Order> _ordersCurrentlyDisplaying;
  int _totalRowCount = 0;

  OrderDataSource({
    required List<Order> ordersCurrentlyDisplaying,
    required this.context,
  }) : _ordersCurrentlyDisplaying = ordersCurrentlyDisplaying;

  void updateTotalRowCount(int total) {
    if (_totalRowCount != total) {
      _totalRowCount = total;
    }
  }

  @override
  DataRow? getRow(int index) {
    final orderBloc = BlocProvider.of<OrderBloc>(context);
    final currentState = orderBloc.state;
    int firstRowIndexOfCurrentPage = 0;
    int itemsPerPage = PaginatedDataTable.defaultRowsPerPage;

    if (currentState is OrdersLoaded) {
      itemsPerPage = currentState.rowsPerPage;
      firstRowIndexOfCurrentPage =
          (currentState.currentPage - 1) * itemsPerPage;
    }

    final int localIndex = index - firstRowIndexOfCurrentPage;

    if (localIndex >= 0 && localIndex < _ordersCurrentlyDisplaying.length) {
      final order = _ordersCurrentlyDisplaying[localIndex];
      return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(Text(order.orderNumber)),
          DataCell(
            Text(order.createdAt.substring(0, 10)),
          ), // Basic date formatting
          DataCell(
            Text("${order.userId.substring(0, 8)}..."),
          ), // Show part of User ID
          DataCell(Text('\$${order.items.length.toStringAsFixed(2)}')),
          // DataCell(Text(order.status.toString())),
          DataCell(
            DropdownButton<String>(
              value: order.status.toString(),
              // Assuming OrderStatus is an enum in Dart or you have a list of strings
              items:
                  [
                    "Pending",
                    "Processing",
                    "Shipped",
                    "Delivered",
                    "Cancelled",
                    "Refunded",
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newStatus) {
                if (newStatus != null && newStatus != order.status) {
                  // Dispatch event to BLoC to update status
                  context.read<OrderBloc>().add(
                    ChangeOrderStatusEvent(
                      orderId: order.id,
                      status: newStatus,
                    ),
                  );
                }
              },
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () {
                    // TODO: Navigate to Order Detail Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'View Order: ${order.id} (Not Implemented)',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Order',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                          'Are you sure you want to delete order ${order.orderNumber}?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              context.read<OrderBloc>().add(
                                DeleteOrderEvent(orderId: order.id),
                              );
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return null;
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _totalRowCount;
  @override
  int get selectedRowCount => 0;

  void sort<T>(Comparable<T> Function(Order o) getField, bool ascending) {
    _ordersCurrentlyDisplaying.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      if (ascending) {
        return Comparable.compare(aValue, bValue);
      } else {
        return Comparable.compare(bValue, aValue);
      }
    });
    notifyListeners();
  }
}
