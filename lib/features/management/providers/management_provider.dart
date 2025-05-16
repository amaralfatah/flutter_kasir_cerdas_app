// lib/features/management/providers/management_provider.dart
import 'package:flutter/material.dart';

class ManagementProvider extends ChangeNotifier {
  // This provider can manage state for management-related features
  // For example, it could track which management sections are active

  final List<String> _managementFeatures = [
    'Product or Service',
    'Product Category',
    'Stock Management',
    'Customer',
    'Credit',
    'Purchase of Goods',
    'Discounts, Taxes and Fees',
    'Stock Opname',
    'Supplier',
    'Department',
    'Marketing',
  ];

  List<String> get managementFeatures => _managementFeatures;

  // Add more management-related state management methods as needed
}
