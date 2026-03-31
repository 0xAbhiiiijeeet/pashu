class ApiEndpoints {
  ApiEndpoints._();

  // API host is controlled here for the whole app.
  static const String baseUrl = 'https://4wtzlrjn-5000.inc1.devtunnels.ms/';

  // Auth
  static const String sendOtp = '/api/auth/send-otp'; // Dev/test only
  static const String verifyOtp = '/api/auth/verify-otp'; // Dev/test only
  static const String verifyFirebaseToken =
      '/api/auth/verify-firebase-token'; // Production
  static const String onboarding = '/api/auth/onboarding';
  static const String profile = '/api/auth/profile';
  static const String profilePic = '/api/auth/profile-pic';

  // Problems
  static const String problems = '/api/problems';

  // Bookings
  static const String bookings = '/api/bookings';
  static const String bookedCalls = '/api/bookings/booked';
  static const String completedCalls = '/api/bookings/completed';
  static const String adminBookings = '/api/bookings/admin/all';
  static String bookingStatus(String id) => '/api/bookings/$id/status';

  // Questions
  static const String questions = '/api/questions';
  static String questionLike(String id) => '/api/questions/$id/like';
  static String questionComments(String id) => '/api/questions/$id/comments';
  static String questionAnswer(String id) => '/api/questions/$id/answer';

  // Posts (Q&A)
  static const String posts = '/api/posts';
  static String postLike(String id) => '/api/posts/$id/like';
  static String postComments(String id) => '/api/posts/$id/comments';
  static String postById(String id) => '/api/posts/$id';
  static String postUpdate(String id) => '/api/posts/$id';
  static String postDelete(String id) => '/api/posts/$id';

  // Subscriptions
  static const String subscriptionTrial = '/api/subscriptions/trial';
  static const String subscriptionSubscribe = '/api/subscriptions/subscribe';
  static const String subscriptionStatus = '/api/subscriptions/status';
  static const String subscriptionForceActive =
      '/api/subscriptions/force-active';
  static String adminSubscriptionForceActive(String id) =>
      '/api/subscriptions/admin/$id/force-active';

  // App Version & Settings
  static const String versionCheck = '/api/settings/version-check';
  static const String settings = '/api/settings';

  // App sharing
  static String get appUrl => 'https://drive.google.com/file/d/1PpHB8_I07gNTKj-j0DII9JEJ5lThZ-a4/view?usp=drive_link';

  // Cow Sales (Marketplace)
  static const String cowSales = '/api/cowsales';
  static const String myCowSales = '/api/cowsales/my-sales';
  static const String cowSaleImages = '/api/cowsales/upload-images';
  static const String adminCowSales = '/api/cowsales/admin';
  static String adminCowSaleStatus(String id) => '/api/cowsales/admin/$id/status';

  // Milk Calculator
  static const String milkCalculate = '/api/milk-calculator/calculate';
  static const String milkHistory = '/api/milk-calculator/history';
  static String milkCalculation(String id) => '/api/milk-calculator/$id';
  static const String milkCustomers = '/api/milk-calculator/customers';
  static const String milkRecords = '/api/milk-calculator/records';
  static const String milkSummary = '/api/milk-calculator/summary';

  // Categories
  static const String categories = '/api/categories';
  static String categoryById(String id) => '/api/categories/$id';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationSchedule = '/api/notifications/schedule';
}
