import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:equatable/equatable.dart';
// Import your Product and ApiResponse models

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final int currentPage;
  final int totalProducts;

  const ProductsLoaded({
    required this.products,
    this.currentPage = 1,
    this.totalProducts = 0,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [products, currentPage];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  const ProductOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
