import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/router/app_router.dart';
import 'core/network/dio_client.dart';
import 'core/providers/remote_config_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'features/bookings/presentation/providers/bookings_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/posts/data/datasources/posts_remote_datasource.dart';
import 'features/posts/presentation/providers/posts_provider.dart';
import 'features/problems/data/datasources/problems_remote_datasource.dart';
import 'features/problems/presentation/providers/problems_provider.dart';
import 'features/questions/data/datasources/questions_remote_datasource.dart';
import 'features/questions/presentation/providers/questions_provider.dart';
import 'features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'features/marketplace/presentation/providers/marketplace_provider.dart';
import 'features/milk_calculator/data/datasources/milk_calculator_remote_datasource.dart';
import 'features/milk_calculator/presentation/providers/milk_calculator_provider.dart';
import 'features/milk/presentation/providers/milk_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'shared/widgets/force_update_wrapper.dart';
import 'shared/widgets/maintenance_wrapper.dart';
import 'firebase_options.dart';

// Global navigator key for programmatic navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📱 Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with timeout
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 15),
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase init timeout or failed: $e');
    // Continue anyway - app might work without Firebase
  }

  // Initialize Remote Config
  try {
    await RemoteConfigService.instance.initialize().timeout(
      const Duration(seconds: 10),
    );
  } catch (e) {
    debugPrint('⚠️ Remote Config init timeout or failed: $e');
    // Continue with default values
  }
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // System UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init storage with timeout to prevent hang
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final storageService = StorageService(secureStorage);
  try {
    await storageService.init().timeout(
      const Duration(seconds: 10),
    );
  } catch (e) {
    debugPrint('⚠️ Storage init timeout or failed: $e');
    // Continue anyway - SharedPreferences might still work
  }

  // Init Dio
  DioClient.instance.init(storageService);
  
  // Initialize notifications with timeout
  try {
    await NotificationService.instance.initialize().timeout(
      const Duration(seconds: 10),
    );
  } catch (e) {
    debugPrint('⚠️ Notification init timeout or failed: $e');
  }

  runApp(PashuMitraApp(storageService: storageService));
}

class PashuMitraApp extends StatelessWidget {
  final StorageService storageService;

  const PashuMitraApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(storageService),
        ),
        ChangeNotifierProvider<RemoteConfigProvider>(
          create: (_) => RemoteConfigProvider()..initialize(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            AuthRemoteDataSource(DioClient.instance),
            storageService,
          )..init(),
        ),
        ChangeNotifierProvider<BookingsProvider>(
          create: (_) => BookingsProvider(
            BookingsRemoteDataSource(DioClient.instance),
            storageService,
          ),
        ),
        ChangeNotifierProvider<ProblemsProvider>(
          create: (_) => ProblemsProvider(
            ProblemsRemoteDataSource(DioClient.instance),
            storageService,
          ),
        ),
        ChangeNotifierProvider<PostsProvider>(
          create: (_) => PostsProvider(
            PostsRemoteDataSource(DioClient.instance.dio),
            storageService,
          ),
        ),
        ChangeNotifierProvider<QuestionsProvider>(
          create: (_) => QuestionsProvider(
            QuestionsRemoteDataSource(DioClient.instance),
          ),
        ),
        ChangeNotifierProvider<MarketplaceProvider>(
          create: (_) => MarketplaceProvider(
            MarketplaceRemoteDataSource(DioClient.instance.dio),
          ),
        ),
        ChangeNotifierProvider<MilkCalculatorProvider>(
          create: (_) => MilkCalculatorProvider(
            MilkCalculatorRemoteDataSource(DioClient.instance.dio),
          ),
        ),
        ChangeNotifierProvider<MilkProvider>(
          create: (_) => MilkProvider(),
        ),
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
        Provider<StorageService>.value(value: storageService),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    
    return MaintenanceWrapper(
      child: ForceUpdateWrapper(
        child: MaterialApp(
          title: 'Pashu Mitr',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorKey: navigatorKey,
          home: const _AuthGate(),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}

// Auth gate that rebuilds when auth state changes
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Show splash during initialization
    if (authProvider.status == 'initial' ||
        authProvider.status == 'loading') {
      return const SplashScreen();
    }
    
    // Show login if unauthenticated
    if (authProvider.status == 'unauthenticated') {
      return const LoginScreen();
    }
    
    // Show home if authenticated
    return const HomeScreen();
  }
}


