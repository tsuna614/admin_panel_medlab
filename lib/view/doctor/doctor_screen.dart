import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_bloc.dart';
import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_states.dart';
import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_events.dart';
import 'package:admin_panel_medlab/models/doctor_model.dart';
import 'package:admin_panel_medlab/view/doctor/create_edit_doctor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorInitial ||
              (state is DoctorLoading &&
                  (state is! DoctorsLoaded ||
                      (state as DoctorsLoaded).doctors.isEmpty))) {
            if (state is DoctorInitial) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Ensure BLoC is available before reading
                if (context.mounted) {
                  context.read<DoctorBloc>().add(
                    FetchDoctorsEvent(
                      page: 1,
                      limit: PaginatedDataTable.defaultRowsPerPage,
                    ),
                  );
                }
              });
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorsLoaded) {
            if (state.doctors.isEmpty && state.totalDoctors == 0) {
              return const Center(
                child: Text('No doctors found. Click + to add one.'),
              );
            }
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DoctorDataTable(
                    doctorsForCurrentPage: state.doctors,
                    totalAvailableDoctors: state.totalDoctors,
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
                          builder: (_) => CreateEditDoctorScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                    child: const Text('Add Doctor'),
                  ),
                ),
              ],
            );
          } else if (state is DoctorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DoctorBloc>().add(
                      FetchDoctorsEvent(
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

class DoctorDataTable extends StatefulWidget {
  final List<Doctor> doctorsForCurrentPage;
  final int totalAvailableDoctors;
  final int rowsPerPage;
  final int currentPageZeroIndexed;

  const DoctorDataTable({
    super.key,
    required this.doctorsForCurrentPage,
    required this.totalAvailableDoctors,
    required this.rowsPerPage,
    required this.currentPageZeroIndexed,
  });

  @override
  State<DoctorDataTable> createState() => _DoctorDataTableState();
}

class _DoctorDataTableState extends State<DoctorDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  DoctorDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _updateDataSource();
  }

  @override
  void didUpdateWidget(covariant DoctorDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctorsForCurrentPage != oldWidget.doctorsForCurrentPage ||
        widget.totalAvailableDoctors != oldWidget.totalAvailableDoctors ||
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
      _dataSource = DoctorDataSource(
        doctorsCurrentlyDisplaying: List.from(widget.doctorsForCurrentPage),
        context: context,
      );
      // Tell the data source the total number of rows available
      _dataSource?.updateTotalRowCount(widget.totalAvailableDoctors);
    }
  }

  void _sort<T>(
    Comparable<T> Function(Doctor p) getField,
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
    final doctorBloc = BlocProvider.of<DoctorBloc>(context);

    if (_dataSource == null) {
      // This might happen briefly if widget rebuilds before _updateDataSource from didUpdateWidget.
      // Or if widget.doctorsForCurrentPage is initially empty but totalAvailableDoctors is > 0.
      // The BLoCBuilder in DoctorScreen should ideally handle the primary loading/empty states.
      return const Center(child: Text("Preparing table..."));
    }

    // PaginatedDataTable handles empty states for the current page view well if rowCount is set.
    return SingleChildScrollView(
      scrollDirection:
          Axis.vertical, // Ensure vertical scrolling for PaginatedDataTable
      child: PaginatedDataTable(
        header: const Text('Doctors'),
        rowsPerPage: widget.rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        initialFirstRowIndex:
            widget.currentPageZeroIndexed * widget.rowsPerPage,
        onRowsPerPageChanged: (value) {
          if (value != null && value != widget.rowsPerPage) {
            doctorBloc.add(FetchDoctorsEvent(page: 1, limit: value));
          }
        },
        onPageChanged: (firstRowIndex) {
          int newPage =
              (firstRowIndex / widget.rowsPerPage).floor() +
              1; // add 1 to convert to 1-indexed page number in the backend
          if (newPage != widget.currentPageZeroIndexed + 1) {
            doctorBloc.add(
              FetchDoctorsEvent(page: newPage, limit: widget.rowsPerPage),
            );
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: Text('Name'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (doctor) => "${doctor.firstName} ${doctor.lastName}",
                columnIndex,
                ascending,
              );
            },
          ),
          DataColumn(
            label: Text('Specialization'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (doctor) => doctor.medicalSpecialty,
                columnIndex,
                ascending,
              );
            },
          ),
          DataColumn(
            label: Text('Consultation Fee'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (doctor) => doctor.consultationFeeRange ?? '',
                columnIndex,
                ascending,
              );
            },
          ),
          DataColumn(
            label: Text('Visible'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                (doctor) => doctor.isVisibleToUsers.toString(),
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

class DoctorDataSource extends DataTableSource {
  final BuildContext context;
  List<Doctor> _doctorsCurrentlyDisplaying;
  int _totalRowCount = 0; // Initialize to 0

  DoctorDataSource({
    required List<Doctor> doctorsCurrentlyDisplaying,
    required this.context,
  }) : _doctorsCurrentlyDisplaying = doctorsCurrentlyDisplaying;

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
    // currently held in _doctorsCurrentlyDisplaying, considering the current page.

    final doctorBloc = BlocProvider.of<DoctorBloc>(context);
    final currentState = doctorBloc.state;
    int firstRowIndexOfCurrentPage = 0;

    if (currentState is DoctorsLoaded) {
      firstRowIndexOfCurrentPage =
          (currentState.currentPage - 1) *
          PaginatedDataTable.defaultRowsPerPage;
    }

    // Calculate the index relative to the current page's data
    final int localIndex = index - firstRowIndexOfCurrentPage;

    if (localIndex >= 0 && localIndex < _doctorsCurrentlyDisplaying.length) {
      final doctor = _doctorsCurrentlyDisplaying[localIndex];
      return DataRow.byIndex(
        // Pass the overall index to DataRow.byIndex for PaginatedDataTable's internal management.
        // This is important for selection and other features if you use them.
        index: index,
        cells: [
          DataCell(Text('${doctor.firstName} ${doctor.lastName}')),
          DataCell(Text(doctor.medicalSpecialty)),
          DataCell(Text(doctor.consultationFeeRange ?? 'Not specified')),
          DataCell(Text(doctor.isVisibleToUsers ? 'Yes' : 'No')),
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
                            CreateEditDoctorScreen(doctorToEdit: doctor),
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
                            'Are you sure you want to delete ${doctor.firstName}?',
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
                                context.read<DoctorBloc>().add(
                                  DeleteDoctorEvent(doctorId: doctor.id),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Delete: ${doctor.firstName}',
                                    ),
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

  void sort<T>(Comparable<T> Function(Doctor p) getField, bool ascending) {
    _doctorsCurrentlyDisplaying.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
