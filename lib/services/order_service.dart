import 'package:admin_panel_medlab/models/order_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

class FetchOrderResponse {
  final int total;
  final int totalPages;
  final int currentPage;
  final List<Order> orders;

  FetchOrderResponse.fromJson(Map<String, dynamic> json)
    : total = json['total'],
      totalPages = json['totalPages'],
      currentPage = json['currentPage'],
      orders = (json['orders'] as List).map((o) => Order.fromJson(o)).toList();
}

abstract class OrderService {
  final ApiClient apiClient;

  OrderService(this.apiClient);

  Future<ApiResponse<FetchOrderResponse>> fetchOrders(
    int? page,
    int? limit,
    String? statusFilter,
  );

  Future<ApiResponse<void>> changeOrderStatus({
    required String orderId,
    required String status,
  });

  Future<ApiResponse<void>> deleteOrder(String orderId);
}

class OrderServiceImpl extends OrderService {
  OrderServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<FetchOrderResponse>> fetchOrders(
    int? page,
    int? limit,
    String? statusFilter,
  ) {
    return apiClient.get<FetchOrderResponse>(
      endpoint: '/orders',
      queryParameters: {'page': page, 'limit': limit, 'status': statusFilter},
      fromJson: (data) => FetchOrderResponse.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<void>> changeOrderStatus({
    required String orderId,
    required String status,
  }) {
    return apiClient.put<void>(
      endpoint: '/orders/updateOrderStatus/$orderId',
      data: {'status': status},
    );
  }

  @override
  Future<ApiResponse<void>> deleteOrder(String orderId) {
    return apiClient.delete<void>(endpoint: '/orders/$orderId');
  }
}
