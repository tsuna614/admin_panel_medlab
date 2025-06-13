import 'package:admin_panel_medlab/models/doctor_model.dart';
import 'package:equatable/equatable.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorsEvent extends DoctorEvent {
  final int? page;
  final int? limit;

  const FetchDoctorsEvent({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class CreateDoctorEvent extends DoctorEvent {
  final Doctor doctor;

  const CreateDoctorEvent({required this.doctor});

  @override
  List<Object?> get props => [doctor];
}

class UpdateDoctorEvent extends DoctorEvent {
  final Doctor doctor;

  const UpdateDoctorEvent({required this.doctor});

  @override
  List<Object?> get props => [doctor];
}

class DeleteDoctorEvent extends DoctorEvent {
  final String doctorId;

  const DeleteDoctorEvent({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}
