class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String currentUser = '/users/me';
  static const String userManagement = '/user-management/users';
  
  // Shop endpoints
  static const String shops = '/shops';
  static const String shopManagement = '/shop-management/shops';
  
  // Product endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  
  // Inventory endpoints
  static const String stockOpname = '/stock-opname';
  static const String stock = '/stock/products';
  
  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String purchaseOrders = '/purchase-orders';
  
  // Customer endpoints
  static const String customers = '/customers';
  
  // Supplier endpoints
  static const String suppliers = '/suppliers';
  
  // Report endpoints
  static const String salesReport = '/reports/sales';
  static const String stockReport = '/reports/stock';
}