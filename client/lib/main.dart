import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/common/theme/app_theme.dart';
import 'package:house_worker/features/auth/login_screen.dart';
import 'package:house_worker/features/home/home_screen.dart';
import 'package:house_worker/services/auth_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/models/user.dart';
import 'package:house_worker/models/household.dart';
import 'package:logging/logging.dart';

// ロガーの設定
final logger = Logger('HouseWorker');

// Isarインスタンスのプロバイダー
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

// Firebase Emulatorの設定を読み込むためのプロバイダー
final emulatorConfigProvider = Provider<Map<String, dynamic>>(
  (ref) => throw UnimplementedError(),
);

// Firebase Emulatorのホスト情報を取得する関数
Future<String> getEmulatorHost() async {
  try {
    // Dart Definesから設定を読み込む
    final String configJson = await rootBundle.loadString(
      'emulator-config.json',
    );
    final Map<String, dynamic> config = json.decode(configJson);
    return config['emulator_host'] ?? 'localhost';
  } catch (e) {
    logger.warning('エミュレーター設定の読み込みに失敗しました: $e');
    // デフォルト値を返す
    return 'localhost';
  }
}

// Firebase Emulatorの設定を行う関数
void setupFirebaseEmulators(String host) {
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // Functionsも使用する場合は以下を追加
  // FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}

void main() async {
  // ロガーの初期化
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase初期化
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart が生成されたらコメントを外す
    );
    logger.info('Firebase initialized successfully');

    // エミュレーターのホスト情報を取得
    final emulatorHost = await getEmulatorHost();
    logger.info('エミュレーターホスト: $emulatorHost');

    // エミュレーターの設定を適用
    setupFirebaseEmulators(emulatorHost);
    logger.info('Firebase Emulator設定を適用しました');
  } catch (e) {
    logger.severe('Failed to initialize Firebase: $e');
    // Firebase が初期化できなくても、アプリを続行する
  }

  // Initialize Isar and store instance for later use
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    UserSchema,
    TaskSchema,
    HouseholdSchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const HouseWorkerApp(),
    ),
  );
}

class HouseWorkerApp extends StatelessWidget {
  const HouseWorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Worker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stackTrace) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('エラーが発生しました'),
                  const SizedBox(height: 10),
                  Text(error.toString()),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(authStateProvider);
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
