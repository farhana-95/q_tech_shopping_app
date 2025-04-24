import '../models/products.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> execute({required int skip, required int limit}) {
    return repository.getProducts(skip: skip, limit: limit);
  }
}