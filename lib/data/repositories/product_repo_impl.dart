import '../../domain/models/products.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getProducts({required int skip, required int limit}) async {
    return await dataSource.getProducts(skip: skip, limit: limit);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await dataSource.searchProducts(query);
  }
}