import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart' as app_user;
import 'package:house_worker/repositories/user_repository.dart';
import 'package:logging/logging.dart';

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
  final Logger _logger = Logger('AuthService');

  AuthService(this._firebaseAuth, this._userRepository);

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

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
      _logger.warning('匿名サインインに失敗しました: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
}
