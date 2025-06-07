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

// Example: AddProductEvent would carry a Product object
// class AddProductEvent extends ProductEvent {
//   final Product product;
//   const AddProductEvent(this.product);
//   @override List<Object> get props => [product];
// }

// Add events for UpdateProduct, DeleteProduct, FetchProductById as needed
