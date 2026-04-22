import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/service_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/location_provider.dart';
import 'providers/notification_provider.dart';
import 'utils/fallback_material_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notifications
  await NotificationService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('om'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProMatchApp(),
    ),
  );
}

class ProMatchApp extends StatefulWidget {
  const ProMatchApp({super.key});

  @override
  State<ProMatchApp> createState() => _ProMatchAppState();
}

class _ProMatchAppState extends State<ProMatchApp> {
  @override
  Widget build(BuildContext context) {
    // Subscribing to context.locale here (EasyLocalization InheritedWidget)
    // ensures this StatefulWidget rebuilds immediately when the user switches
    // languages, so MaterialApp.locale is always up to date.
    final currentLocale = context.locale;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, child) {
          return MaterialApp(
            title: 'ProMatch',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            locale: currentLocale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: [
              const FallbackMaterialLocalizationsDelegate(),
              const FallbackCupertinoLocalizationsDelegate(),
              ...context.localizationDelegates,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
