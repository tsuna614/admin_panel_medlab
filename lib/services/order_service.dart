import 'package:admin_panel_medlab/models/order_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

abstract class OrderService {
  final ApiClient apiClient;

  OrderService(this.apiClient);

  Future<ApiResponse<Order>> fetchOrders();

  Future<ApiResponse<Order>> changeOrderStatus({
    required String orderId,
    required OrderStatus status,
  });
}
