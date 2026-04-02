import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/sync_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/services/hive_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/secure_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await HiveService.init();
  await NotificationService.init();

  final supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  final supabaseAnonKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureLocalStorage(),
        ),
      );
      runApp(
        ProviderScope(
          overrides: [
            isSupabaseConfiguredProvider.overrideWith((ref) => true),
          ],
          child: const ForjaApp(),
        ),
      );
      return;
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  runApp(
    ProviderScope(
      child: const ForjaApp(),
    ),
  );
}

class ForjaApp extends ConsumerWidget {
  const ForjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Initialize sync listener on boot
    ref.watch(syncProvider);

    return MaterialApp.router(
      title: 'FORJA',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
