import 'package:admin_panel_medlab/models/doctor_model.dart';
import 'package:equatable/equatable.dart';
// Import your Doctor and ApiResponse models

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorsLoaded extends DoctorState {
  final List<Doctor> doctors;
  final int currentPage;
  final int totalDoctors;

  const DoctorsLoaded({
    required this.doctors,
    this.currentPage = 1,
    this.totalDoctors = 0,
  });

  DoctorsLoaded copyWith({
    List<Doctor>? doctors,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return DoctorsLoaded(
      doctors: doctors ?? this.doctors,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [doctors, currentPage];
}

class DoctorOperationSuccess extends DoctorState {
  final String message;
  const DoctorOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);

  @override
  List<Object> get props => [message];
}
