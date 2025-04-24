import '../models/products.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({required int skip, required int limit});
  Future<List<Product>> searchProducts(String query);
}
