import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pochi_trim/ui/feature/settings/section_header.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  static const name = 'DebugScreen';

  static MaterialPageRoute<DebugScreen> route() =>
      MaterialPageRoute<DebugScreen>(
        builder: (_) => const DebugScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('デバッグ')),
      body: ListView(
        children: const [
          SectionHeader(title: 'Crashlytics'),
          _ForceErrorTile(),
          _ForceCrashTile(),
        ],
      ),
    );
  }
}

class _ForceCrashTile extends StatelessWidget {
  const _ForceCrashTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('強制クラッシュ'),
      onTap: () => FirebaseCrashlytics.instance.crash(),
    );
  }
}

class _ForceErrorTile extends StatelessWidget {
  const _ForceErrorTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(title: const Text('強制エラー'), onTap: () => throw Exception());
  }
}
