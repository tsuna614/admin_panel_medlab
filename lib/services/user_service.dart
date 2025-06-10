import 'package:admin_panel_medlab/models/user_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

class FetchUserResponse {
  final int total;
  final int totalPages;
  final int currentPage;
  final List<User> users;

  FetchUserResponse.fromJson(Map<String, dynamic> json)
    : total = json['total'],
      totalPages = json['totalPages'],
      currentPage = json['currentPage'],
      users = (json['users'] as List).map((u) => User.fromJson(u)).toList();
}

abstract class UserService {
  final ApiClient apiClient;

  UserService(this.apiClient);

  Future<ApiResponse<FetchUserResponse>> fetchUsers(
    int? page,
    int? limit,
    String? searchValue,
  );
}

class UserServiceImpl extends UserService {
  UserServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<FetchUserResponse>> fetchUsers(
    int? page,
    int? limit,
    String? searchValue,
  ) {
    return apiClient.get<FetchUserResponse>(
      endpoint: '/users/getAllUsers',
      queryParameters: {
        'page': page,
        'limit': limit,
        'searchValue': searchValue,
      },
      fromJson: (data) => FetchUserResponse.fromJson(data),
    );
  }
}
