import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/products.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts({required int skip, required int limit});

  Future<List<Product>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Product>> getProducts(
      {required int skip, required int limit}) async {
    final response = await client.get(
      Uri.parse('https://dummyjson.com/products?skip=$skip&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List productList = jsonData['products'];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await client.get(
      Uri.parse('https://dummyjson.com/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List productList = jsonData['products'];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }
}
