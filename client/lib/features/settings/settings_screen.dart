import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart' as app_user;
import 'package:house_worker/repositories/user_repository.dart';
import 'package:house_worker/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// 現在のユーザー情報を取得するプロバイダー
final currentUserProvider = FutureProvider.autoDispose<app_user.User?>((
  ref,
) async {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  final currentUser = authService.currentUser;
  if (currentUser != null) {
    try {
      final user = await userRepository.getUserByUid(currentUser.uid);
      print('ユーザー情報を取得しました: ${user?.name}');
      return user;
    } catch (e) {
      print('ユーザー情報の取得に失敗しました: $e');
      return null;
    }
  }
  return null;
});

// アプリのバージョン情報を取得するプロバイダー
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('ユーザー情報が取得できません'));
          }

          return ListView(
            children: [
              // ユーザー情報セクション
              _buildSectionHeader(context, 'ユーザー情報'),
              _buildUserInfoTile(context, user, ref),

              // 家の情報セクション
              _buildSectionHeader(context, '家の情報'),
              _buildHouseholdTile(context, user),
              _buildShareHouseTile(context),

              const Divider(),

              // アプリ情報セクション
              _buildSectionHeader(context, 'アプリについて'),
              _buildReviewTile(context),
              _buildShareAppTile(context),
              _buildTermsOfServiceTile(context),
              _buildPrivacyPolicyTile(context),

              // デバッグセクション
              _buildSectionHeader(context, 'デバッグ'),
              _buildDebugTile(context),

              // バージョン情報
              _buildVersionInfo(context, packageInfoAsync),

              const Divider(),

              // アカウント管理セクション
              _buildSectionHeader(context, 'アカウント管理'),
              _buildLogoutTile(context, ref),
              _buildDeleteAccountTile(context, ref, user),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUserInfoTile(
    BuildContext context,
    app_user.User user,
    WidgetRef ref,
  ) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text('ユーザー名'),
      subtitle: Text(user.name),
      trailing: const Icon(Icons.edit),
      onTap: () => _showEditNameDialog(context, user, ref),
    );
  }

  Widget _buildHouseholdTile(BuildContext context, app_user.User user) {
    return ListTile(
      leading: const Icon(Icons.home),
      title: const Text('家の設定'),
      subtitle: Text(
        user.householdIds.isNotEmpty
            ? '${user.householdIds.length}件の家に参加中'
            : '家に参加していません',
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 家の設定画面への遷移処理
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('家の設定画面は現在開発中です')));
      },
    );
  }

  Widget _buildShareHouseTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group_add),
      title: const Text('家を共有する'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 家の共有処理
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('家の共有機能は現在開発中です')));
      },
    );
  }

  Widget _buildReviewTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star),
      title: const Text('アプリをレビューする'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        // レビューページへのリンク
        final url = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.houseworker',
        );
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

  Widget _buildShareAppTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('友達に教える'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

  Widget _buildDebugTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: const Text('デバッグ画面'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // デバッグ画面への遷移処理
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('デバッグ画面は現在開発中です')));
      },
    );
  }

  Widget _buildVersionInfo(
    BuildContext context,
    AsyncValue<PackageInfo> packageInfoAsync,
  ) {
    return packageInfoAsync.when(
      data: (packageInfo) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'バージョン: ${packageInfo.version} (${packageInfo.buildNumber})',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
      loading: () => const Center(child: Text('バージョン情報を読み込み中...')),
      error: (_, __) => const Center(child: Text('バージョン情報を取得できませんでした')),
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
    app_user.User user,
  ) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('アカウントを削除', style: TextStyle(color: Colors.red)),
      onTap: () => _showDeleteAccountConfirmDialog(context, ref, user),
    );
  }

  // ユーザー名編集ダイアログ
  void _showEditNameDialog(
    BuildContext context,
    app_user.User user,
    WidgetRef ref,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ユーザー名の変更'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '新しいユーザー名',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    // ユーザー名の更新処理
                    final updatedUser = app_user.User(
                      id: user.id,
                      uid: user.uid,
                      name: newName,
                      email: user.email,
                      householdIds: user.householdIds,
                      createdAt: user.createdAt,
                      isPremium: user.isPremium,
                    );

                    try {
                      await ref
                          .read(userRepositoryProvider)
                          .updateUser(updatedUser);
                      ref.invalidate(currentUserProvider); // プロバイダーを更新

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ユーザー名を更新しました')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('エラーが発生しました: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
    );
  }

  // ログアウト確認ダイアログ
  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
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
                    if (context.mounted) {
                      Navigator.pop(context); // ダイアログを閉じる
                      Navigator.pop(context); // 設定画面を閉じる
                    }
                  } catch (e) {
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
    app_user.User user,
  ) {
    showDialog(
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
                    // ユーザーデータの削除
                    await ref.read(userRepositoryProvider).delete(user.id);

                    // Firebase認証からのサインアウト
                    await ref.read(authServiceProvider).signOut();

                    if (context.mounted) {
                      Navigator.pop(context); // ダイアログを閉じる
                      Navigator.pop(context); // 設定画面を閉じる

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('アカウントを削除しました')),
                      );
                    }
                  } catch (e) {
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
