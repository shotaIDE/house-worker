import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart' as app_user;
import 'package:house_worker/repositories/user_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthService(firebase_auth.FirebaseAuth.instance, userRepository);
});

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  AuthService(this._firebaseAuth, this._userRepository);

  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  Future<void> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        // ユーザーがデータベースに存在するか確認
        final existingUser = await _userRepository.getUserByUid(user.uid);

        if (existingUser == null) {
          // 新規ユーザーを作成
          final newUser = app_user.User(
            id: '', // 新規ユーザーの場合は空文字列を指定し、Firestoreが自動的にIDを生成
            uid: user.uid,
            name: 'ゲスト',
            email: user.email ?? '',
            householdIds: [],
            createdAt: DateTime.now(),
          );

          await _userRepository.createUser(newUser);
        }
      }
    } catch (e) {
      print('匿名サインインに失敗しました: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
}
