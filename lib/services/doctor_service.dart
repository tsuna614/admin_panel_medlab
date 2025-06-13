import 'package:admin_panel_medlab/models/doctor_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

class FetchDoctorResponse {
  final int total;
  final int totalPages;
  final int currentPage;
  final List<Doctor> doctors;

  FetchDoctorResponse.fromJson(Map<String, dynamic> json)
    : total = json['total'],
      totalPages = json['totalPages'],
      currentPage = json['currentPage'],
      doctors = (json['doctors'] as List)
          .map((p) => Doctor.fromJson(p))
          .toList();
}

abstract class DoctorService {
  final ApiClient apiClient;

  DoctorService(this.apiClient);

  Future<ApiResponse<FetchDoctorResponse>> fetchDoctors(int? page, int? limit);

  Future<ApiResponse<Doctor>> fetchDoctorById(String doctorId);

  Future<ApiResponse<void>> createDoctor(Doctor doctor);

  Future<ApiResponse<void>> updateDoctor(Doctor doctor);

  Future<ApiResponse<void>> deleteDoctor(String doctorId);
}

class DoctorServiceImpl extends DoctorService {
  DoctorServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<FetchDoctorResponse>> fetchDoctors(int? page, int? limit) {
    return apiClient.get<FetchDoctorResponse>(
      endpoint: '/doctors',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => FetchDoctorResponse.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<Doctor>> fetchDoctorById(String doctorId) {
    return apiClient.get<Doctor>(
      endpoint: '/doctors/$doctorId',
      fromJson: (data) => Doctor.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<void>> createDoctor(Doctor doctor) {
    return apiClient.post<void>(endpoint: '/doctors', data: doctor.toJson());
  }

  @override
  Future<ApiResponse<void>> updateDoctor(Doctor doctor) {
    return apiClient.put<void>(
      endpoint: '/doctors/${doctor.id}',
      data: doctor.toJson(),
    );
  }

  @override
  Future<ApiResponse<void>> deleteDoctor(String doctorId) {
    return apiClient.delete<void>(endpoint: '/doctors/$doctorId');
  }
}
