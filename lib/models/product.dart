// lib/models/product.dart - Updated for the exact API response
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'product_category.dart';

class Product {
  final int id;
  final String name;
  final String sku;
  final int categoryId;
  final double purchasePrice;
  final double sellingPrice;
  final String? barcode;
  final String? description;
  final List<String>? images;
  final bool isUsingStock;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final ProductCategory? category;
  final List<ProductStock>? stocks;
  final List<dynamic>? priceRules;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    this.barcode,
    this.description,
    this.images,
    required this.isUsingStock,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.category,
    this.stocks,
    this.priceRules,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse purchase_price and selling_price which are strings in the API
    double parsePurchasePrice() {
      if (json['purchase_price'] == null) return 0.0;
      if (json['purchase_price'] is double) {
        return json['purchase_price'];
      } else if (json['purchase_price'] is String) {
        return double.tryParse(json['purchase_price']) ?? 0.0;
      }
      return 0.0;
    }

    double parseSellingPrice() {
      if (json['selling_price'] == null) return 0.0;
      if (json['selling_price'] is double) {
        return json['selling_price'];
      } else if (json['selling_price'] is String) {
        return double.tryParse(json['selling_price']) ?? 0.0;
      }
      return 0.0;
    }

    // Handle images (null in the provided example)
    List<String>? parseImages() {
      if (json['images'] == null) return null;
      if (json['images'] is String) {
        try {
          final dynamic parsed = jsonDecode(json['images']);
          if (parsed is List) {
            return List<String>.from(parsed);
          }
          return [json['images']];
        } catch (e) {
          return [json['images']];
        }
      } else if (json['images'] is List) {
        return List<String>.from(json['images']);
      }
      return null;
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      categoryId: json['category_id'] ?? 0,
      purchasePrice: parsePurchasePrice(),
      sellingPrice: parseSellingPrice(),
      barcode: json['barcode'],
      description: json['description'],
      images: parseImages(),
      isUsingStock: json['is_using_stock'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      category: json['category'] != null 
        ? ProductCategory.fromJson(json['category']) 
        : null,
      stocks: json['stocks'] != null 
        ? List<ProductStock>.from(
            json['stocks'].map((x) => ProductStock.fromJson(x)))
        : null,
      priceRules: json['price_rules'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category_id': categoryId,
      'purchase_price': purchasePrice.toString(),
      'selling_price': sellingPrice.toString(),
      'barcode': barcode,
      'description': description,
      'images': images,
      'is_using_stock': isUsingStock,
      'is_active': isActive,
    };
  }
}

class ProductStock {
  final int id;
  final int productId;
  final int shopId;
  final int stock; // Changed from quantity to stock to match API
  final int minStock;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  ProductStock({
    required this.id,
    required this.productId,
    required this.shopId,
    required this.stock,
    required this.minStock,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'shop_id': shopId,
      'stock': stock,
      'min_stock': minStock,
    };
  }
}