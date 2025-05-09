import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/auth/login_presenter.dart';
import 'package:house_worker/features/home/home_screen.dart';
import 'package:house_worker/models/sign_in_result.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const name = 'LoginScreen';

  static MaterialPageRoute<LoginScreen> route() =>
      MaterialPageRoute<LoginScreen>(
        builder: (_) => const LoginScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();

    ref.listenManual(loginButtonTappedResultProvider, (previous, next) {
      next.maybeWhen(
        error: (_, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ログインに失敗しました。しばらくしてから再度お試しください。')),
          );
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginButton = ElevatedButton(
      onPressed: _onLoginTapped,
      child: const Text('ゲストとしてログイン'),
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'House Worker',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('家事を簡単に記録・管理できるアプリ', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 60),
            loginButton,
          ],
        ),
      ),
    );
  }

  Future<void> _onLoginTapped() async {
    try {
      await ref.read(loginButtonTappedResultProvider.notifier).onLoginTapped();
    } on SignInException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインに失敗しました。しばらくしてから再度お試しください。')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(HomeScreen.route());
  }
}
