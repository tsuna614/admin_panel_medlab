import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_events.dart';
import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_states.dart';
import 'package:admin_panel_medlab/services/doctor_service.dart';
import 'package:bloc/bloc.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorService doctorService;
  final int itemsPerPage = 10;

  DoctorBloc({required this.doctorService}) : super(DoctorInitial()) {
    on<FetchDoctorsEvent>(_onFetchDoctors);
    on<CreateDoctorEvent>(_onAddDoctor);
    on<UpdateDoctorEvent>(_onUpdateDoctor);
    on<DeleteDoctorEvent>(_onDeleteDoctor);
  }

  Future<void> _onFetchDoctors(
    FetchDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    final response = await doctorService.fetchDoctors(
      event.page ?? 1,
      event.limit ?? itemsPerPage,
    );

    if (response.statusCode == 200 && response.data != null) {
      final doctorResponse = response.data!;

      emit(
        DoctorsLoaded(
          doctors: doctorResponse.doctors,
          currentPage: doctorResponse.currentPage,
          totalDoctors: doctorResponse.total,
        ),
      );
    } else {
      emit(
        DoctorError(response.errorMessage ?? "Unknown error fetching doctors."),
      );
    }
  }

  Future<void> _onAddDoctor(
    CreateDoctorEvent event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      emit(DoctorLoading());
      final response = await doctorService.createDoctor(event.doctor);
      if (response.statusCode == 200) {
        add(
          FetchDoctorsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(DoctorError(response.errorMessage ?? "Error adding doctor."));
      }
    } else {
      emit(DoctorError("Cannot add doctor, doctors not loaded."));
    }
  }

  Future<void> _onUpdateDoctor(
    UpdateDoctorEvent event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      emit(DoctorLoading());
      final response = await doctorService.updateDoctor(event.doctor);
      if (response.statusCode == 200) {
        emit(DoctorOperationSuccess("Doctor updated successfully."));
        add(
          FetchDoctorsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(DoctorError(response.errorMessage ?? "Error updating doctor."));
      }
    } else {
      emit(DoctorError("Cannot update doctor, doctors not loaded."));
    }
  }

  Future<void> _onDeleteDoctor(
    DeleteDoctorEvent event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final response = await doctorService.deleteDoctor(event.doctorId);
      if (response.statusCode == 200) {
        emit(DoctorOperationSuccess("Doctor deleted successfully."));
        add(
          FetchDoctorsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(DoctorError(response.errorMessage ?? "Error deleting doctor."));
      }
    } else {
      emit(DoctorError("Cannot delete doctor, doctors not loaded."));
    }
  }
}
