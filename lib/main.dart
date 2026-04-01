import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'app/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/network/dio_client.dart';
import 'core/providers/remote_config_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/remote_config_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'features/bookings/presentation/providers/bookings_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'features/marketplace/presentation/providers/marketplace_provider.dart';
import 'features/milk/data/datasources/milk_remote_datasource.dart';
import 'features/milk/presentation/providers/milk_provider.dart';
import 'features/milk_calculator/data/datasources/milk_calculator_remote_datasource.dart';
import 'features/milk_calculator/presentation/providers/milk_calculator_provider.dart';
import 'features/posts/data/datasources/posts_remote_datasource.dart';
import 'features/posts/presentation/providers/posts_provider.dart';
import 'features/problems/data/datasources/problems_remote_datasource.dart';
import 'features/problems/presentation/providers/problems_provider.dart';
import 'features/questions/data/datasources/questions_remote_datasource.dart';
import 'features/questions/presentation/providers/questions_provider.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'shared/widgets/force_update_wrapper.dart';
import 'shared/widgets/maintenance_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Starting app bootstrap...');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final storageService = StorageService(secureStorage);

  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase init timeout or failed: $e');
  }

  try {
    await RemoteConfigService.instance.initialize().timeout(
      const Duration(seconds: 8),
    );
    debugPrint('✅ Remote Config initialized successfully');
    debugPrint('📡 Base URL: ${RemoteConfigService.instance.baseUrl}');
  } catch (e) {
    debugPrint('❌ Remote Config init timeout or failed: $e');
  }

  try {
    await storageService.init().timeout(const Duration(seconds: 5));
    debugPrint('Storage initialized successfully');
  } catch (e) {
    debugPrint('Storage init timeout or failed: $e');
  }

  DioClient.instance.init(storageService);

  runApp(PashuMitraApp(storageService: storageService));

  _initializeBackgroundServices();
}

Future<void> _initializeBackgroundServices() async {
  debugPrint('Starting background service initialization...');

  try {
    await NotificationService.instance.initialize().timeout(
      const Duration(seconds: 8),
    );
    debugPrint('Notification service initialized successfully');
  } catch (e) {
    debugPrint('Notification init timeout or failed: $e');
  }
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
          create: (_) => RemoteConfigProvider(),
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
          create: (_) => MilkProvider(
            MilkRemoteDataSource(DioClient.instance.dio),
          ),
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

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.status == 'initial' || authProvider.status == 'loading') {
      return const SplashScreen();
    }

    if (authProvider.status == 'unauthenticated') {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}

