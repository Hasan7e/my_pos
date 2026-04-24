import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/product.dart';

class ProductStore {
  ProductStore._();

  static final ProductStore instance = ProductStore._();

  Box<Product> get _box => Hive.box<Product>('products');

  List<Product> get products => _box.values.toList();

  ValueListenable<Box<Product>> listenable() => _box.listenable();

  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
    await _box.flush();
  }

  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product);
    await _box.flush();
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
    await _box.flush();
  }

  Product? findByBarcode(String barcode) {
    final normalized = barcode.trim();
    for (final product in _box.values) {
      if (product.barcode == normalized) {
        return product;
      }
    }
    return null;
  }

  List<Product> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return products;

    return _box.values.where((product) {
      return product.name.toLowerCase().contains(normalized) ||
          product.barcode.toLowerCase().contains(normalized);
    }).toList();
  }

  bool barcodeExists(String barcode, {String? ignoreId}) {
    for (final product in _box.values) {
      if (product.barcode == barcode && product.id != ignoreId) {
        return true;
      }
    }
    return false;
  }
}
