import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

abstract class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<ApiResponse<List<Product>>> fetchProducts(int? page, int? limit);

  Future<ApiResponse<Product>> fetchProductById(String productId);

  Future<ApiResponse<Product>> createProduct(Product product);

  Future<ApiResponse<Product>> updateProduct(Product product);

  Future<ApiResponse<void>> deleteProduct(String productId);
}

class ProductServiceImpl extends ProductService {
  ProductServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<List<Product>>> fetchProducts(int? page, int? limit) {
    return apiClient.get<List<Product>>(
      endpoint: '/products',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => (data as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<Product>> fetchProductById(String productId) {
    return apiClient.get<Product>(
      endpoint: '/products/$productId',
      fromJson: (data) => Product.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<Product>> createProduct(Product product) {
    return apiClient.post<Product>(
      endpoint: '/products',
      data: product.toJson(),
      fromJson: (data) => Product.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<Product>> updateProduct(Product product) {
    return apiClient.put<Product>(
      endpoint: '/products/${product.id}',
      data: product.toJson(),
      fromJson: (data) => Product.fromJson(data),
    );
  }

  @override
  Future<ApiResponse<void>> deleteProduct(String productId) {
    return apiClient.delete<void>(endpoint: '/products/$productId');
  }
}
