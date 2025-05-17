import 'package:flutter/material.dart';

class ProductCategory {
  final int id;
  final String name;
  final int? parentId;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    // Handle the case where parent_id might come as a string from the API
    int? parsedParentId;
    if (json['parent_id'] != null) {
      if (json['parent_id'] is int) {
        parsedParentId = json['parent_id'] as int;
      } else if (json['parent_id'] is String) {
        // Try to parse as int if it's a string
        if (json['parent_id'] != 'null' && json['parent_id'].isNotEmpty) {
          try {
            parsedParentId = int.parse(json['parent_id']);
          } catch (e) {
            debugPrint(
                'Error parsing parent_id "${json['parent_id']}" as int: $e');
          }
        }
      }
    }

    // Handle boolean conversion for is_active field
    bool isActive = true;
    if (json['is_active'] != null) {
      if (json['is_active'] is bool) {
        isActive = json['is_active'];
      } else if (json['is_active'] is int) {
        isActive = json['is_active'] == 1;
      } else if (json['is_active'] is String) {
        isActive = json['is_active'].toLowerCase() == 'true' ||
            json['is_active'] == '1';
      }
    }

    return ProductCategory(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'],
      parentId: parsedParentId,
      isActive: isActive,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'is_active': isActive,
    };
  }
}
