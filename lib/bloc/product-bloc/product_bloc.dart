import 'package:admin_panel_medlab/bloc/product-bloc/product_events.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_states.dart';
import 'package:admin_panel_medlab/services/product_service.dart';
import 'package:bloc/bloc.dart';
// Import your events, states, ProductService, and Product model

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService productService; // Use the abstract class type
  final int itemsPerPage = 10; // Example for pagination

  ProductBloc({required this.productService}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<CreateProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final response = await productService.fetchProducts(
      event.page ?? 1,
      event.limit ?? itemsPerPage,
    );

    if (response.statusCode == 200 && response.data != null) {
      final productResponse = response.data!;

      emit(
        ProductsLoaded(
          products: productResponse.products,
          currentPage: productResponse.currentPage,
          totalProducts: productResponse.total,
        ),
      );
    } else {
      emit(
        ProductError(
          response.errorMessage ?? "Unknown error fetching products.",
        ),
      );
    }
  }

  Future<void> _onAddProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    // final response = await productService.createProduct(event.product);
    // if (response.statusCode == 200 && response.data != null) {
    //   emit(ProductOperationSuccess("Product added successfully."));
    //   // Optionally, you can trigger a fetch to refresh the product list
    //   add(FetchProductsEvent());
    // } else {
    //   emit(ProductError(response.errorMessage ?? "Error adding product."));
    // }

    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(ProductLoading());
      final response = await productService.createProduct(event.product);
      if (response.statusCode == 200) {
        add(
          FetchProductsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(ProductError(response.errorMessage ?? "Error adding product."));
      }
    } else {
      emit(ProductError("Cannot add product, products not loaded."));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(ProductLoading());
      final response = await productService.updateProduct(event.product);
      if (response.statusCode == 200) {
        emit(ProductOperationSuccess("Product updated successfully."));
        add(
          FetchProductsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(ProductError(response.errorMessage ?? "Error updating product."));
      }
    } else {
      emit(ProductError("Cannot update product, products not loaded."));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final response = await productService.deleteProduct(event.productId);
      if (response.statusCode == 200) {
        emit(ProductOperationSuccess("Product deleted successfully."));
        add(
          FetchProductsEvent(
            page: currentState.currentPage,
            limit: itemsPerPage,
          ),
        );
      } else {
        emit(ProductError(response.errorMessage ?? "Error deleting product."));
      }
    } else {
      emit(ProductError("Cannot delete product, products not loaded."));
    }
  }

  // Future<void> _onFetchNextProductPage(
  //   FetchNextProductPageEvent event,
  //   Emitter<ProductState> emit,
  // ) async {
  //   if (state is ProductsLoaded) {
  //     final currentState = state as ProductsLoaded;
  //     if (currentState.hasReachedMax) return; // No more pages

  //     // Don't emit ProductLoading if we are just appending to avoid full screen spinner
  //     // You might want a specific 'LoadingMoreProducts' state or use a flag in ProductsLoaded

  //     final nextPage = currentState.currentPage + 1;
  //     final response = await productService.fetchProducts(
  //       nextPage,
  //       itemsPerPage,
  //     );

  //     if (response.isSuccess && response.data != null) {
  //       emit(
  //         ProductsLoaded(
  //           products:
  //               currentState.products + response.data!, // Append new products
  //           currentPage: response.currentPage ?? nextPage,
  //           hasReachedMax:
  //               (response.currentPage ?? nextPage) >=
  //               (response.totalPages ?? 1),
  //         ),
  //       );
  //     } else {
  //       // Don't change to ProductError if some products are already loaded,
  //       // maybe show a snackbar or a small error indicator at the bottom.
  //       // For simplicity, emitting error here.
  //       emit(
  //         ProductError(response.errorMessage ?? "Error fetching next page."),
  //       );
  //     }
  //   }
  // }
}
