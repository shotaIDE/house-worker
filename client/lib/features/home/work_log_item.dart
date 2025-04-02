import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/home/work_log_add_dialog.dart';
import 'package:house_worker/features/home/work_log_provider.dart';
import 'package:house_worker/models/work_log.dart';
import 'package:intl/intl.dart';

class WorkLogItem extends ConsumerWidget {
  const WorkLogItem({
    super.key,
    required this.workLog,
    required this.onTap,
    this.onComplete,
  });

  final WorkLog workLog;
  final VoidCallback onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('workLog-${workLog.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // ワークログ削除処理
        ref.read(workLogDeletionProvider).deleteWorkLog(workLog);

        // スナックバーを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('家事ログを削除しました')),
              ],
            ),
            action: SnackBarAction(
              label: '元に戻す',
              onPressed: () {
                // 削除を取り消す
                ref.read(workLogDeletionProvider).undoDelete();
              },
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // アイコンを表示
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 12),
                      child: Text(
                        workLog.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        workLog.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 記録ボタンを追加
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'この家事を記録する',
                      onPressed: () {
                        // 家事ログ追加ダイアログを表示
                        showWorkLogAddDialog(
                          context,
                          ref,
                          existingWorkLog: workLog,
                        ).then((updated) {
                          // 家事ログが追加された場合（updatedがtrue）、データを更新
                          if (updated == true) {
                            ref
                              ..invalidate(completedWorkLogsProvider)
                              ..invalidate(frequentlyCompletedWorkLogsProvider);
                          }
                        });
                      },
                    ),
                    // 完了ボタンを追加（onCompleteが提供されている場合のみ表示）
                    if (onComplete != null && !workLog.isCompleted)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'この家事を完了としてマーク',
                        onPressed: onComplete,
                        color: Colors.green,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child:
                          workLog.isCompleted
                              ? _CompletedDateText(
                                completedAt: workLog.completedAt,
                              )
                              : const Text(
                                '未完了',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        workLog.isCompleted
                            ? '実行者: ${workLog.completedBy ?? "不明"}'
                            : '作成者: ${workLog.createdBy}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedDateText extends StatelessWidget {
  const _CompletedDateText({required this.completedAt});

  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return Text(
      '完了: ${dateFormat.format(completedAt ?? DateTime.now())}',
      style: const TextStyle(fontSize: 14, color: Colors.grey),
      overflow: TextOverflow.ellipsis,
    );
  }
}
