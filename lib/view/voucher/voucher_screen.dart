import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_bloc.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_states.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_events.dart';
import 'package:admin_panel_medlab/models/voucher_model.dart';
import 'package:admin_panel_medlab/view/voucher/create_edit_voucher_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          if (state is VoucherInitial ||
              (state is VoucherLoading &&
                  (state is! VouchersLoaded ||
                      (state as VouchersLoaded).vouchers.isEmpty))) {
            if (state is VoucherInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Ensure BLoC is available before reading
                if (context.mounted) {
                  context.read<VoucherBloc>().add(
                    FetchVouchersEvent(
                      page: 1,
                      limit: PaginatedDataTable.defaultRowsPerPage,
                    ),
                  );
                }
              });
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is VouchersLoaded) {
            if (state.vouchers.isEmpty && state.totalVouchers == 0) {
              return const Center(
                child: Text('No vouchers found. Click + to add one.'),
              );
            }
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: VoucherDataTable(
                    vouchersForCurrentPage: state.vouchers,
                    totalAvailableVouchers: state.totalVouchers,
                    rowsPerPage: PaginatedDataTable.defaultRowsPerPage,
                    currentPageZeroIndexed: state.currentPage - 1,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateEditVoucherScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: const Text('Add Voucher'),
                  ),
                ),
              ],
            );
          } else if (state is VoucherError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VoucherBloc>().add(
                      FetchVouchersEvent(
                        page: 1,
                        limit: PaginatedDataTable.defaultRowsPerPage,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}

class VoucherDataTable extends StatefulWidget {
  final List<Voucher> vouchersForCurrentPage;
  final int totalAvailableVouchers;
  final int rowsPerPage;
  final int currentPageZeroIndexed;

  const VoucherDataTable({
    super.key,
    required this.vouchersForCurrentPage,
    required this.totalAvailableVouchers,
    required this.rowsPerPage,
    required this.currentPageZeroIndexed,
  });

  @override
  State<VoucherDataTable> createState() => _VoucherDataTableState();
}

class _VoucherDataTableState extends State<VoucherDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  VoucherDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  @override
  void didUpdateWidget(covariant VoucherDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vouchersForCurrentPage != oldWidget.vouchersForCurrentPage ||
        widget.totalAvailableVouchers != oldWidget.totalAvailableVouchers ||
        widget.rowsPerPage != oldWidget.rowsPerPage ||
        widget.currentPageZeroIndexed !=
            oldWidget
                .currentPageZeroIndexed // Check if current page changed too
                ) {
      _updateDataSource();
    }
  }

  void _updateDataSource() {
    // Ensure the context is still valid, though less critical here as it's for BLoC access in source
    if (mounted) {
      _dataSource = VoucherDataSource(
        vouchersCurrentlyDisplaying: List.from(widget.vouchersForCurrentPage),
        context: context,
      );
      // Tell the data source the total number of rows available
      _dataSource?.updateTotalRowCount(widget.totalAvailableVouchers);
    }
  }

  void _sort<T>(
    Comparable<T> Function(Voucher p) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataSource?.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final voucherBloc = BlocProvider.of<VoucherBloc>(context);

    if (_dataSource == null) {
      // This might happen briefly if widget rebuilds before _updateDataSource from didUpdateWidget.
      // Or if widget.vouchersForCurrentPage is initially empty but totalAvailableVouchers is > 0.
      // The BLoCBuilder in VoucherScreen should ideally handle the primary loading/empty states.
      return const Center(child: Text("Preparing table..."));
    }

    // PaginatedDataTable handles empty states for the current page view well if rowCount is set.
    return SingleChildScrollView(
      scrollDirection:
          Axis.vertical, // Ensure vertical scrolling for PaginatedDataTable
      child: PaginatedDataTable(
        header: const Text('Vouchers'),
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        initialFirstRowIndex:
            widget.currentPageZeroIndexed * widget.rowsPerPage,
        onRowsPerPageChanged: (value) {
          if (value != null && value != widget.rowsPerPage) {
            voucherBloc.add(FetchVouchersEvent(page: 1, limit: value));
          }
        },
        onPageChanged: (firstRowIndex) {
          int newPage =
              (firstRowIndex / widget.rowsPerPage).floor() +
              1; // add 1 to convert to 1-indexed page number in the backend
          if (newPage != widget.currentPageZeroIndexed + 1) {
            voucherBloc.add(
              FetchVouchersEvent(page: newPage, limit: widget.rowsPerPage),
            );
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: Text('Title'),
            onSort: (columnIndex, ascending) {
              _sort<String>((voucher) => voucher.title, columnIndex, ascending);
            },
          ),
          DataColumn(
            label: Text('Code'),
            onSort: (columnIndex, ascending) {
              _sort<String>((voucher) => voucher.code, columnIndex, ascending);
            },
          ),
          DataColumn(
            label: Text('Discount %'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (voucher) => voucher.discount.toString(),
                columnIndex,
                ascending,
              );
            },
          ),
          DataColumn(
            label: Text('Visible'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (voucher) => voucher.isVisibleToUsers.toString(),
                columnIndex,
                ascending,
              );
            },
          ),
          const DataColumn(label: Text('Actions')),
        ],
        source: _dataSource!,
      ),
    );
  }
}

class VoucherDataSource extends DataTableSource {
  final BuildContext context;
  List<Voucher> _vouchersCurrentlyDisplaying;
  int _totalRowCount = 0; // Initialize to 0

  VoucherDataSource({
    required List<Voucher> vouchersCurrentlyDisplaying,
    required this.context,
  }) : _vouchersCurrentlyDisplaying = vouchersCurrentlyDisplaying;

  void updateTotalRowCount(int total) {
    if (_totalRowCount != total) {
      _totalRowCount = total;
      // No need to call notifyListeners() just for rowCount change,
      // PaginatedDataTable will re-query getRow and rowCount.
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    // PaginatedDataTable passes the overall index (0 to _totalRowCount - 1).
    // We need to determine if this 'index' falls within the range of items
    // currently held in _vouchersCurrentlyDisplaying, considering the current page.

    final voucherBloc = BlocProvider.of<VoucherBloc>(context);
    final currentState = voucherBloc.state;
    int firstRowIndexOfCurrentPage = 0;

    if (currentState is VouchersLoaded) {
      firstRowIndexOfCurrentPage =
          (currentState.currentPage - 1) *
          PaginatedDataTable.defaultRowsPerPage;
    }

    // Calculate the index relative to the current page's data
    final int localIndex = index - firstRowIndexOfCurrentPage;

    if (localIndex >= 0 && localIndex < _vouchersCurrentlyDisplaying.length) {
      final voucher = _vouchersCurrentlyDisplaying[localIndex];
      return DataRow.byIndex(
        // Pass the overall index to DataRow.byIndex for PaginatedDataTable's internal management.
        // This is important for selection and other features if you use them.
        index: index,
        cells: [
          DataCell(Text(voucher.title)),
          DataCell(Text(voucher.code)),
          DataCell(Text('${voucher.discount}%')),
          DataCell(Text(voucher.isVisibleToUsers ? 'Yes' : 'No')),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateEditVoucherScreen(voucherToEdit: voucher),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text(
                            'Are you sure you want to delete ${voucher.title}?',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            TextButton(
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                context.read<VoucherBloc>().add(
                                  DeleteVoucherEvent(voucherId: voucher.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Delete: ${voucher.title}'),
                                  ),
                                );
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    return null; // Return null if index is out of bounds for the current page's data
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _totalRowCount;

  @override
  int get selectedRowCount => 0;

  void sort<T>(Comparable<T> Function(Voucher p) getField, bool ascending) {
    _vouchersCurrentlyDisplaying.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
