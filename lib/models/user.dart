import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? shopId;
  final bool isActive;
  final Shop? shop;
  final List<ShopOwnership>? ownedShops;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.shopId,
    required this.isActive,
    this.shop,
    this.ownedShops,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      shopId: json['shop_id'],
      isActive: json['is_active'],
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
      ownedShops: json['owned_shops'] != null 
          ? List<ShopOwnership>.from(
              json['owned_shops'].map((x) => ShopOwnership.fromJson(x)))
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'shop_id': shopId,
      'is_active': isActive,
      'shop': shop?.toJson(),
      'owned_shops': ownedShops?.map((x) => x.toJson()).toList(),
    };
  }
  
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  static User? fromJsonString(String jsonString) {
    try {
      return User.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
  
  // Check if user is owner
  bool get isOwner => role == 'owner';
  
  // Check if user is admin or above
  bool get isAdmin => role == 'admin' || role == 'owner';
  
  // Check if user is manager or above
  bool get isManager => role == 'manager' || isAdmin;
  
  // Check if user is cashier
  bool get isCashier => role == 'cashier';
}

class Shop {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? taxId;
  final bool isActive;
  
  Shop({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.taxId,
    required this.isActive,
  });
  
  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      taxId: json['tax_id'],
      isActive: json['is_active'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'tax_id': taxId,
      'is_active': isActive,
    };
  }
}

class ShopOwnership {
  final int id;
  final int userId;
  final int shopId;
  final bool isPrimaryOwner;
  final String? notes;
  final Shop? shop;
  
  ShopOwnership({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.isPrimaryOwner,
    this.notes,
    this.shop,
  });
  
  factory ShopOwnership.fromJson(Map<String, dynamic> json) {
    return ShopOwnership(
      id: json['id'],
      userId: json['user_id'],
      shopId: json['shop_id'],
      isPrimaryOwner: json['is_primary_owner'],
      notes: json['notes'],
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'is_primary_owner': isPrimaryOwner,
      'notes': notes,
      'shop': shop?.toJson(),
    };
  }
}