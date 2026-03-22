import 'package:flutter/material.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/questions/presentation/screens/animal_problems_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/milk_calculator/presentation/screens/milk_calculator_screen.dart';
import '../../features/milk/presentation/screens/milk_khata_dashboard_screen.dart';
import '../../features/milk/presentation/screens/add_customer_screen.dart';
import '../../features/milk/presentation/screens/add_milk_entry_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_home_screen.dart';
import '../../features/marketplace/presentation/screens/buy_cattle_screen.dart';
import '../../features/marketplace/presentation/screens/sell_cattle_screen.dart';

class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String animalProblems = '/animal-problems';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String milkCalculator = '/milk-calculator';
  static const String milkKhata = '/milk-khata';
  static const String addCustomer = '/add-customer';
  static const String addMilkEntry = '/add-milk-entry';
  static const String marketplace = '/marketplace';
  static const String buyCattle = '/buy-cattle';
  static const String sellCattle = '/sell-cattle';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🔧 Generating route for: ${settings.name}');
    
    try {
      switch (settings.name) {
        case RouteNames.login:
          return MaterialPageRoute(builder: (_) => const LoginScreen());

        case RouteNames.otp:
          final args = settings.arguments as Map<String, dynamic>?;
          final phone = args?['phoneNumber'] as String? ?? '';
          return MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone));

        case RouteNames.home:
          return MaterialPageRoute(builder: (_) => const HomeScreen());

        case RouteNames.animalProblems:
          return MaterialPageRoute(builder: (_) => const AnimalProblemsScreen());

        case RouteNames.profile:
          return MaterialPageRoute(builder: (_) => const ProfileScreen());

        case RouteNames.subscription:
          return MaterialPageRoute(builder: (_) => const SubscriptionScreen());

        case RouteNames.milkCalculator:
          return MaterialPageRoute(builder: (_) => const MilkCalculatorScreen());

        case RouteNames.milkKhata:
          return MaterialPageRoute(builder: (_) => const MilkKhataDashboardScreen());

        case RouteNames.addCustomer:
          return MaterialPageRoute(builder: (_) => const AddCustomerScreen());

        case RouteNames.addMilkEntry:
          return MaterialPageRoute(builder: (_) => const AddMilkEntryScreen());

        case RouteNames.marketplace:
          return MaterialPageRoute(builder: (_) => const MarketplaceHomeScreen());

        case RouteNames.buyCattle:
          return MaterialPageRoute(builder: (_) => const BuyCattleScreen());

        case RouteNames.sellCattle:
          return MaterialPageRoute(builder: (_) => const SellCattleScreen());

        default:
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Route not found: ${settings.name}')),
            ),
          );
      }
    } catch (e, stackTrace) {
      print('❌ Error generating route: $e');
      print('Stack: $stackTrace');
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      );
    }
  }

  /// Guard: Navigate based on auth state
  static String initialRoute(AuthProvider authProvider) {
    print('🔧 Determining initial route...');
    print('🔧 Auth status: ${authProvider.status}');
    print('🔧 User: ${authProvider.user?.name}');
    
    try {
      switch (authProvider.status) {
        case 'authenticated':
          print('🔧 Returning home route');
          return RouteNames.home;
        case 'unauthenticated':
        default:
          print('🔧 Returning login route');
          return RouteNames.login;
      }
    } catch (e, stackTrace) {
      print('❌ Error in initialRoute: $e');
      print('Stack: $stackTrace');
      return RouteNames.login;
    }
  }
}
