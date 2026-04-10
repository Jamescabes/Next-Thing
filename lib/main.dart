import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'demo_config.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/notification_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kDemoMode) {
    // Firebase init
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Notification service init (skip on web — not supported)
  if (!kIsWeb) {
    try {
      await NotificationService().initialize();
    } catch (_) {}
  }

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const NextThingApp());
}

class NextThingApp extends StatelessWidget {
  const NextThingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => ap.AuthProvider()..init(),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..init(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Next Thing',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            home: const _AppRouter(),
          );
        },
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final tasks = context.read<TaskProvider>();

    switch (auth.status) {
      case ap.AuthStatus.unknown:
        return const SplashScreen();

      case ap.AuthStatus.authenticated:
        final uid = auth.uid!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tasks.init(uid); // idempotente: ignora si ya está inicializado para este uid
        });
        return const HomeScreen();

      case ap.AuthStatus.unauthenticated:
        // Reset tasks on logout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tasks.reset();
        });
        return const LoginScreen();
    }
  }
}
