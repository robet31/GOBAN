/// Route path constants for GoRouter
class Routes {
  Routes._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String roleSelect = '/role-select';

  // Customer
  static const String home = '/home';
  static const String map = '/home/map';
  static const String orders = '/home/orders';
  static const String profile = '/home/profile';

  // Order
  static const String createOrder = '/order/create';
  static const String orderDetail = '/order/:orderId';
  static const String orderTracking = '/order/:orderId/tracking';
  static const String payment = '/order/:orderId/payment';
  static const String review = '/order/:orderId/review';
  static const String waitingOrder = '/order/:orderId/waiting';

  // Technician
  static const String technicianRegister = '/technician/register';
  static const String technicianDashboard = '/technician/dashboard';
  static const String verificationPending = '/technician/pending';

  // UGC Locations
  static const String addLocation = '/locations/add';

  // Chat
  static const String chat = '/chat/:orderId';

  // Profile
  static const String editProfile = '/profile/edit';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminVerifyTechnicians = '/admin/verify-technicians';
  static const String adminModerateLocations = '/admin/moderate-locations';
  static const String adminManageOrders = '/admin/manage-orders';
  static const String adminManageUsers = '/admin/manage-users';

  // Helper methods for parameterized routes
  static String orderDetailPath(String orderId) => '/order/$orderId';
  static String orderTrackingPath(String orderId) => '/order/$orderId/tracking';
  static String paymentPath(String orderId) => '/order/$orderId/payment';
  static String reviewPath(String orderId) => '/order/$orderId/review';
  static String waitingOrderPath(String orderId) => '/order/$orderId/waiting';
  static String chatPath(String orderId) => '/chat/$orderId';
}
