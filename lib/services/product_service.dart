import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:admin_panel_medlab/services/api_client.dart';

class ProductResponse {
  final int total;
  final int totalPages;
  final int currentPage;
  final List<Product> products;

  ProductResponse.fromJson(Map<String, dynamic> json)
    : total = json['total'],
      totalPages = json['totalPages'],
      currentPage = json['currentPage'],
      products = (json['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
}

abstract class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<ApiResponse<ProductResponse>> fetchProducts(int? page, int? limit);

  Future<ApiResponse<Product>> fetchProductById(String productId);

  Future<ApiResponse<Product>> createProduct(Product product);

  Future<ApiResponse<Product>> updateProduct(Product product);

  Future<ApiResponse<void>> deleteProduct(String productId);
}

class ProductServiceImpl extends ProductService {
  ProductServiceImpl(super.apiClient);

  @override
  Future<ApiResponse<ProductResponse>> fetchProducts(int? page, int? limit) {
    return apiClient.get<ProductResponse>(
      endpoint: '/products',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => ProductResponse.fromJson(data),
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
