import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:equatable/equatable.dart';
// Import your Product model if needed for events like AddProduct

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final int? page;
  final int? limit;
  // Add category, searchTerm if needed

  const FetchProductsEvent({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class FetchNextProductPageEvent extends ProductEvent {}

// Example: CreateProductEvent would carry a Product object
// class CreateProductEvent extends ProductEvent {
//   final Product product;
//   const CreateProductEvent(this.product);
//   @override List<Object> get props => [product];
// }

class CreateProductEvent extends ProductEvent {
  final Product product;

  const CreateProductEvent({required this.product});

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

// Add events for UpdateProduct, DeleteProduct, FetchProductById as needed
