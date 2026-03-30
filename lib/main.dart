import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/sync_provider.dart';
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

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://fjsgcacjbxyoxctmvvqq.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZqc2djYWNqYnh5b3hjdG12dnFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NjI0MDQsImV4cCI6MjA4OTIzODQwNH0.MRdxPFgFFLUqNiaO_uKGBfY1zmW4mAEcNZV6apEHDBA'),
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );
  await NotificationService.init();

  runApp(const ProviderScope(child: ForjaApp()));
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
