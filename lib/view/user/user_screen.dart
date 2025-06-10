import 'package:admin_panel_medlab/bloc/user-bloc/user_bloc.dart';
import 'package:admin_panel_medlab/bloc/user-bloc/user_events.dart';
import 'package:admin_panel_medlab/bloc/user-bloc/user_states.dart';
import 'package:admin_panel_medlab/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchValue = ''; // To keep track of the active search

  @override
  void initState() {
    super.initState();
    // Initial fetch is triggered by BlocBuilder if state is UserInitial
  }

  void _performSearch() {
    final searchValue = _searchController.text.trim();
    setState(() {
      _currentSearchValue = searchValue; // Update the active search term
    });
    // Fetch page 0 with the new search term
    context.read<UserBloc>().add(
      FetchUsersEvent(
        page: 0,
        limit: PaginatedDataTable.defaultRowsPerPage,
        searchValue: searchValue,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Users (Name or Email)',
                      hintText: 'Enter search term...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch(); // Perform search with empty term (show all)
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) =>
                        _performSearch(), // Optional: search on submit from keyboard
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- End Search Bar ---
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserInitial ||
                      (state is UserLoading && state is! UserLoaded)) {
                    if (state is UserInitial) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          context.read<UserBloc>().add(
                            FetchUsersEvent(
                              page: 0,
                              limit: PaginatedDataTable.defaultRowsPerPage,
                              searchValue:
                                  _currentSearchValue, // Use current search term
                            ),
                          );
                        }
                      });
                    }
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    if (state.users.isEmpty) {
                      return Center(
                        child: Text(
                          _currentSearchValue.isNotEmpty
                              ? 'No users found for "$_currentSearchValue".'
                              : 'No users available.',
                        ),
                      );
                    }
                    return UserDataTable(
                      users: state.users,
                      totalUsers: state.totalUsers,
                      rowsPerPage: state.rowsPerPage,
                      currentPageZeroIndexed: state.currentPage - 1,
                      currentSearchValue:
                          state.currentSearchValue ?? _currentSearchValue,
                    );
                  } else if (state is UserError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          ElevatedButton(
                            onPressed: () => context.read<UserBloc>().add(
                              FetchUsersEvent(
                                page: 0,
                                limit: PaginatedDataTable.defaultRowsPerPage,
                                searchValue: _currentSearchValue,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Something went wrong with users.'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // You might not have a FAB to create users directly as admin,
      // or it could be part of a different workflow.
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('Navigate to Create User Screen');
      //   },
      //   tooltip: 'Add User',
      //   child: const Icon(Icons.person_add),
      // ),
    );
  }
}

class UserDataTable extends StatefulWidget {
  final List<User> users;
  final int totalUsers;
  final int rowsPerPage;
  final int currentPageZeroIndexed;
  final String? currentSearchValue; // To pass search term for pagination calls

  const UserDataTable({
    Key? key,
    required this.users,
    required this.totalUsers,
    required this.rowsPerPage,
    required this.currentPageZeroIndexed,
    this.currentSearchValue,
  }) : super(key: key);

  @override
  State<UserDataTable> createState() => _UserDataTableState();
}

class _UserDataTableState extends State<UserDataTable> {
  UserDataDataSource? _dataSource;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  @override
  void didUpdateWidget(covariant UserDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.users != oldWidget.users ||
        widget.totalUsers != oldWidget.totalUsers ||
        widget.rowsPerPage != oldWidget.rowsPerPage ||
        widget.currentPageZeroIndexed != oldWidget.currentPageZeroIndexed) {
      _updateDataSource();
    }
  }

  void _updateDataSource() {
    if (mounted) {
      _dataSource = UserDataDataSource(
        usersCurrentlyDisplaying: List.from(widget.users),
        context: context,
      );
      _dataSource?.updateTotalRowCount(widget.totalUsers);
    }
  }

  void _sort<T>(
    Comparable<T> Function(User u) getField,
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
    final userBloc = BlocProvider.of<UserBloc>(context);
    if (_dataSource == null)
      return const Center(child: Text("Preparing user table..."));

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: const Text('Users'),
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        initialFirstRowIndex:
            widget.currentPageZeroIndexed * widget.rowsPerPage,
        onRowsPerPageChanged: (value) {
          if (value != null && value != widget.rowsPerPage) {
            userBloc.add(
              FetchUsersEvent(
                page: 0,
                limit: value,
                searchValue: widget.currentSearchValue, // Preserve search term
              ),
            );
          }
        },
        onPageChanged: (firstRowIndex) {
          int newPage = (firstRowIndex / widget.rowsPerPage).floor() + 1;
          if (newPage != widget.currentPageZeroIndexed + 1) {
            userBloc.add(
              FetchUsersEvent(
                page: newPage,
                limit: widget.rowsPerPage,
                searchValue: widget.currentSearchValue, // Preserve search term
              ),
            );
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: const Text('Name'),
            onSort: (ci, asc) =>
                _sort<String>((u) => "${u.firstName} ${u.lastName}", ci, asc),
          ),
          DataColumn(
            label: const Text('Email'),
            onSort: (ci, asc) => _sort<String>((u) => u.email, ci, asc),
          ),
          DataColumn(
            label: const Text('Role'),
            onSort: (ci, asc) =>
                _sort<String>((u) => u.userType ?? '', ci, asc),
          ),
          const DataColumn(label: Text('Actions')),
        ],
        source: _dataSource!,
      ),
    );
  }
}

class UserDataDataSource extends DataTableSource {
  final BuildContext context;
  List<User> _usersCurrentlyDisplaying;
  int _totalRowCount = 0;

  UserDataDataSource({
    required List<User> usersCurrentlyDisplaying,
    required this.context,
  }) : _usersCurrentlyDisplaying = usersCurrentlyDisplaying;

  void updateTotalRowCount(int total) {
    if (_totalRowCount != total) {
      _totalRowCount = total;
    }
  }

  @override
  DataRow? getRow(int index) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final currentState = userBloc.state;
    int firstRowIndexOfCurrentPage = 0;
    int itemsPerPage = PaginatedDataTable.defaultRowsPerPage;

    if (currentState is UserLoaded) {
      itemsPerPage = currentState.rowsPerPage;
      firstRowIndexOfCurrentPage =
          (currentState.currentPage - 1) * itemsPerPage;
    }
    final int localIndex = index - firstRowIndexOfCurrentPage;

    if (localIndex >= 0 && localIndex < _usersCurrentlyDisplaying.length) {
      final user = _usersCurrentlyDisplaying[localIndex];
      return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(Text("${user.firstName} ${user.lastName}")),
          DataCell(Text(user.email)),
          DataCell(Text(user.userType ?? 'customer')),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                  onPressed: () {
                    _showUserDetailsDialog(context, user);
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

  void sort<T>(Comparable<T> Function(User u) getField, bool ascending) {
    _usersCurrentlyDisplaying.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}

void _showUserDetailsDialog(BuildContext context, User user) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('User Details: ${user.firstName} ${user.lastName}'),
        content: SingleChildScrollView(
          // Use SingleChildScrollView if content might overflow
          child: ListBody(
            // ListBody arranges children vertically
            children: <Widget>[
              _buildDetailRow('ID:', user.id),
              _buildDetailRow('Email:', user.email),
              _buildDetailRow('First Name:', user.firstName),
              _buildDetailRow('Last Name:', user.lastName),
              if (user.number != null && user.number!.isNotEmpty)
                _buildDetailRow('Phone:', user.number!),
              if (user.userType != null && user.userType!.isNotEmpty)
                _buildDetailRow('User Type:', user.userType!),
              // Add Address details if available
              if (user.address != null) ...[
                // Use spread operator for conditional list elements
                const Divider(height: 20),
                const Text(
                  'Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildDetailRow('  Street:', user.address!.street),
                _buildDetailRow('  City:', user.address!.city),
                _buildDetailRow('  State:', user.address?.state ?? ""),
                _buildDetailRow(
                  '  Postal Code:',
                  user.address?.postalCode ?? "",
                ),
                _buildDetailRow('  Country:', user.address!.country),
              ],
              // Add Receipts ID if available and you want to display them
              if (user.receiptsId != null && user.receiptsId!.isNotEmpty) ...[
                const Divider(height: 20),
                const Text(
                  'Receipt IDs:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (String receiptId in user.receiptsId!)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                    child: Text(receiptId),
                  ),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
          ),
        ],
      );
    },
  );
}

// Helper to build a detail row consistently
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
