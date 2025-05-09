import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/definition/app_definition.dart';
import 'package:house_worker/features/settings/debug_screen.dart';
import 'package:house_worker/features/settings/section_header.dart';
import 'package:house_worker/models/user_profile.dart';
import 'package:house_worker/root_presenter.dart';
import 'package:house_worker/services/app_info_service.dart';
import 'package:house_worker/services/auth_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const name = 'SettingsScreen';

  static MaterialPageRoute<SettingsScreen> route() =>
      MaterialPageRoute<SettingsScreen>(
        builder: (_) => const SettingsScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('ユーザー情報が取得できませんでした'));
          }

          return ListView(
            children: [
              const SectionHeader(title: 'ユーザー情報'),
              _buildUserInfoTile(context, userProfile, ref),
              const Divider(),
              const SectionHeader(title: 'アプリについて'),
              const _ReviewAppTile(),
              _buildShareAppTile(context),
              _buildTermsOfServiceTile(context),
              _buildPrivacyPolicyTile(context),
              _buildLicenseTile(context),
              const SectionHeader(title: 'デバッグ'),
              _buildDebugTile(context),
              const _AppVersionTile(),
              const Divider(),
              const SectionHeader(title: 'アカウント管理'),
              _buildLogoutTile(context, ref),
              _buildDeleteAccountTile(context, ref, userProfile),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildUserInfoTile(
    BuildContext context,
    UserProfile userProfile,
    WidgetRef ref,
  ) {
    final String subtitle;
    final VoidCallback? onTap;

    switch (userProfile) {
      case UserProfileAnonymous():
        subtitle = 'ゲスト';
        onTap = () => _showAnonymousUserInfoDialog(context);
      case UserProfileWithAccount(displayName: final displayName):
        subtitle = displayName ?? '名前未設定';
        onTap = null;
    }

    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('ユーザー名'),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildShareAppTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('友達に教える'),
      onTap: () {
        // シェア機能
        Share.share(
          '家事管理アプリ「House Worker」を使ってみませんか？ https://example.com/houseworker',
        );
      },
    );
  }

  Widget _buildTermsOfServiceTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description),
      title: const Text('利用規約'),
      trailing: const _OpenTrailingIcon(),
      onTap: () async {
        // 利用規約ページへのリンク
        final url = Uri.parse('https://example.com/terms');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
          }
        }
      },
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: const Text('プライバシーポリシー'),
      trailing: const _OpenTrailingIcon(),
      onTap: () async {
        // プライバシーポリシーページへのリンク
        final url = Uri.parse('https://example.com/privacy');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
          }
        }
      },
    );
  }

  Widget _buildLicenseTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('ライセンス'),
      trailing: const _MoveScreenTrailingIcon(),
      onTap: () {
        // ライセンス表示画面へ遷移
        showLicensePage(
          context: context,
          applicationName: 'House Worker',
          applicationLegalese: ' 2025 House Worker',
        );
      },
    );
  }

  Widget _buildDebugTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: const Text('デバッグ画面'),
      trailing: const _MoveScreenTrailingIcon(),
      onTap: () => Navigator.of(context).push(DebugScreen.route()),
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
      onTap: () => _showLogoutConfirmDialog(context, ref),
    );
  }

  Widget _buildDeleteAccountTile(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
  ) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('アカウントを削除', style: TextStyle(color: Colors.red)),
      onTap: () => _showDeleteAccountConfirmDialog(context, ref, userProfile),
    );
  }

  // 匿名ユーザー情報ダイアログ
  void _showAnonymousUserInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('匿名ユーザー情報'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('現在、匿名ユーザーとしてログインしています。'),
                SizedBox(height: 8),
                Text('アカウント登録をすると、以下の機能が利用できるようになります：'),
                SizedBox(height: 8),
                Text('• データのバックアップと復元'),
                Text('• 複数のデバイスでの同期'),
                Text('• 家族や友人との家事の共有'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  // ログアウト確認ダイアログ
  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ログアウト'),
            content: const Text('本当にログアウトしますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(authServiceProvider).signOut();
                    await ref
                        .read(currentAppSessionProvider.notifier)
                        .signOut();
                  } on Exception catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ログアウトに失敗しました: $e')),
                      );
                    }
                  }
                },
                child: const Text('ログアウト'),
              ),
            ],
          ),
    );
  }

  // アカウント削除確認ダイアログ
  void _showDeleteAccountConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
  ) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('アカウント削除'),
            content: const Text('本当にアカウントを削除しますか？この操作は元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  try {
                    // Firebase認証からのサインアウト
                    await ref.read(authServiceProvider).signOut();
                    await ref
                        .read(currentAppSessionProvider.notifier)
                        .signOut();
                  } on Exception catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('アカウント削除に失敗しました: $e')),
                      );
                    }
                  }
                },
                child: const Text('削除する'),
              ),
            ],
          ),
    );
  }
}

class _ReviewAppTile extends StatelessWidget {
  const _ReviewAppTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star),
      title: const Text('アプリをレビューする'),
      trailing: const _OpenTrailingIcon(),
      // アプリ内レビューは表示回数に制限があるため、ストアに移動するようにしている
      onTap:
          () => InAppReview.instance.openStoreListing(appStoreId: appStoreId),
    );
  }
}

class _OpenTrailingIcon extends StatelessWidget {
  const _OpenTrailingIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.open_in_browser);
  }
}

class _MoveScreenTrailingIcon extends StatelessWidget {
  const _MoveScreenTrailingIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.arrow_forward_ios, size: 16);
  }
}

class _AppVersionTile extends ConsumerWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersionAsync = ref.watch(currentAppVersionProvider);

    final versionString = appVersionAsync.when(
      data:
          (appVersion) =>
              'バージョン: ${appVersion.version} (${appVersion.buildNumber})',
      loading: () => 'バージョン: n.n.n (nnn)',
      error: (_, _) => 'バージョン情報を取得できませんでした',
    );
    final versionText = Text(
      versionString,
      style: Theme.of(
        context,
      ).textTheme.labelLarge!.copyWith(color: Theme.of(context).dividerColor),
    );

    return Center(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Skeletonizer(
            enabled: appVersionAsync.isLoading,
            child: versionText,
          ),
        ),
      ),
    );
  }
}
