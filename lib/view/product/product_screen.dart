import 'package:admin_panel_medlab/bloc/product-bloc/product_bloc.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_events.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_states.dart';
import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:admin_panel_medlab/view/product/create_edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductInitial ||
              (state is ProductLoading &&
                  (state is! ProductsLoaded ||
                      (state as ProductsLoaded).products.isEmpty))) {
            if (state is ProductInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Ensure BLoC is available before reading
                if (context.mounted) {
                  context.read<ProductBloc>().add(
                    FetchProductsEvent(
                      page: 1,
                      limit: PaginatedDataTable.defaultRowsPerPage,
                    ),
                  );
                }
              });
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty && state.totalProducts == 0) {
              return const Center(
                child: Text('No products found. Click + to add one.'),
              );
            }
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ProductDataTable(
                    productsForCurrentPage: state.products,
                    totalAvailableProducts: state.totalProducts,
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
                          builder: (_) => CreateEditProductScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: const Text('Add Product'),
                  ),
                ),
              ],
            );
          } else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProductBloc>().add(
                      FetchProductsEvent(
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

class ProductDataTable extends StatefulWidget {
  final List<Product> productsForCurrentPage;
  final int totalAvailableProducts;
  final int rowsPerPage;
  final int currentPageZeroIndexed;

  const ProductDataTable({
    super.key,
    required this.productsForCurrentPage,
    required this.totalAvailableProducts,
    required this.rowsPerPage,
    required this.currentPageZeroIndexed,
  });

  @override
  State<ProductDataTable> createState() => _ProductDataTableState();
}

class _ProductDataTableState extends State<ProductDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  ProductDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  @override
  void didUpdateWidget(covariant ProductDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.productsForCurrentPage != oldWidget.productsForCurrentPage ||
        widget.totalAvailableProducts != oldWidget.totalAvailableProducts ||
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
      _dataSource = ProductDataSource(
        productsCurrentlyDisplaying: List.from(widget.productsForCurrentPage),
        context: context,
      );
      // Tell the data source the total number of rows available
      _dataSource?.updateTotalRowCount(widget.totalAvailableProducts);
    }
  }

  void _sort<T>(
    Comparable<T> Function(Product p) getField,
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
    final productBloc = BlocProvider.of<ProductBloc>(context);

    if (_dataSource == null) {
      // This might happen briefly if widget rebuilds before _updateDataSource from didUpdateWidget.
      // Or if widget.productsForCurrentPage is initially empty but totalAvailableProducts is > 0.
      // The BLoCBuilder in ProductScreen should ideally handle the primary loading/empty states.
      return const Center(child: Text("Preparing table..."));
    }

    // PaginatedDataTable handles empty states for the current page view well if rowCount is set.
    return SingleChildScrollView(
      scrollDirection:
          Axis.vertical, // Ensure vertical scrolling for PaginatedDataTable
      child: PaginatedDataTable(
        header: const Text('Products'),
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        initialFirstRowIndex:
            widget.currentPageZeroIndexed * widget.rowsPerPage,
        onRowsPerPageChanged: (value) {
          if (value != null && value != widget.rowsPerPage) {
            productBloc.add(FetchProductsEvent(page: 1, limit: value));
          }
        },
        onPageChanged: (firstRowIndex) {
          int newPage =
              (firstRowIndex / widget.rowsPerPage).floor() +
              1; // add 1 to convert to 1-indexed page number in the backend
          if (newPage != widget.currentPageZeroIndexed + 1) {
            productBloc.add(
              FetchProductsEvent(page: newPage, limit: widget.rowsPerPage),
            );
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('Name'),
            onSort: (columnIndex, ascending) =>
                _sort<String>((p) => p.name, columnIndex, ascending),
          ),
          DataColumn(
            label: const Text('Brand'),
            onSort: (columnIndex, ascending) =>
                _sort<String>((p) => p.brand ?? "", columnIndex, ascending),
          ),
          DataColumn(
            label: const Text('Price'),
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((p) => p.price, columnIndex, ascending),
          ),
          DataColumn(
            label: const Text('Stock'),
            numeric: true,
            onSort: (columnIndex, ascending) =>
                _sort<num>((p) => p.stock, columnIndex, ascending),
          ),
          const DataColumn(label: Text('Actions')),
        ],
        source: _dataSource!,
      ),
    );
  }
}

class ProductDataSource extends DataTableSource {
  final BuildContext context;
  List<Product> _productsCurrentlyDisplaying;
  int _totalRowCount = 0; // Initialize to 0

  ProductDataSource({
    required List<Product> productsCurrentlyDisplaying,
    required this.context,
  }) : _productsCurrentlyDisplaying = productsCurrentlyDisplaying;

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
    // currently held in _productsCurrentlyDisplaying, considering the current page.

    final productBloc = BlocProvider.of<ProductBloc>(context);
    final currentState = productBloc.state;
    int firstRowIndexOfCurrentPage = 0;

    if (currentState is ProductsLoaded) {
      firstRowIndexOfCurrentPage =
          (currentState.currentPage - 1) *
          PaginatedDataTable.defaultRowsPerPage;
    }

    // Calculate the index relative to the current page's data
    final int localIndex = index - firstRowIndexOfCurrentPage;

    if (localIndex >= 0 && localIndex < _productsCurrentlyDisplaying.length) {
      final product = _productsCurrentlyDisplaying[localIndex];
      return DataRow.byIndex(
        // Pass the overall index to DataRow.byIndex for PaginatedDataTable's internal management.
        // This is important for selection and other features if you use them.
        index: index,
        cells: [
          DataCell(Text(product.name)),
          DataCell(Text(product.brand ?? 'N/A')),
          DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
          DataCell(Text(product.stock.toString())),
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
                            CreateEditProductScreen(productToEdit: product),
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
                            'Are you sure you want to delete ${product.name}?',
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
                                context.read<ProductBloc>().add(
                                  DeleteProductEvent(productId: product.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Delete: ${product.name}'),
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

  void sort<T>(Comparable<T> Function(Product p) getField, bool ascending) {
    _productsCurrentlyDisplaying.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
