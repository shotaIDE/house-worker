import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/home/task_log_add_screen.dart';
import 'package:house_worker/features/home/task_log_detail_screen.dart';
import 'package:house_worker/features/home/task_log_item.dart';
import 'package:house_worker/features/home/task_log_provider.dart';
import 'package:house_worker/features/settings/settings_screen.dart';
import 'package:house_worker/services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 完了済みタスクを取得
    final completedTasksAsync = ref.watch(completedTasksProvider);

    // 削除されたタスクを監視
    final deletedTask = ref.watch(deletedTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家事ログ一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: completedTasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '完了した家事ログはありません',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '家事を完了すると、ここに表示されます',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // プロバイダーを更新して最新のデータを取得
                    ref.invalidate(completedTasksProvider);
                  },
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskLogItem(
                        task: task,
                        onTap: () {
                          // タスク詳細画面に遷移
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => TaskLogDetailScreen(task: task),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) =>
                      Center(child: Text('エラーが発生しました: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // タスク追加画面に遷移
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const TaskLogAddScreen(),
                ),
              )
              .then((updated) {
                // 家事ログが追加された場合（updatedがtrue）、データを更新
                if (updated == true) {
                  ref.invalidate(completedTasksProvider);
                }
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
