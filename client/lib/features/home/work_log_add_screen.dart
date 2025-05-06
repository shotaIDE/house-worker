import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/home/add_house_work_presenter.dart';
import 'package:house_worker/features/pro/pro_upgrade_screen.dart';
import 'package:house_worker/models/house_work.dart';
import 'package:house_worker/models/max_house_work_limit_exceeded_exception.dart';
import 'package:house_worker/services/auth_service.dart';

// ランダムな絵文字を生成するためのリスト
const _emojiList = <String>[
  '🧹',
  '🧼',
  '🧽',
  '🧺',
  '🛁',
  '🚿',
  '🚽',
  '🧻',
  '🧯',
  '🔥',
  '💧',
  '🌊',
  '🍽️',
  '🍴',
  '🥄',
  '🍳',
  '🥘',
  '🍲',
  '🥣',
  '🥗',
  '🧂',
  '🧊',
  '🧴',
  '🧷',
  '🧺',
  '🧹',
  '🧻',
  '🧼',
  '🧽',
  '🧾',
  '📱',
  '💻',
  '🖥️',
  '🖨️',
  '⌨️',
  '🖱️',
  '🧮',
  '📔',
  '📕',
  '📖',
  '📗',
  '📘',
  '📙',
  '📚',
  '📓',
  '📒',
  '📃',
  '📜',
  '📄',
  '📰',
];

// ランダムな絵文字を取得する関数
String getRandomEmoji() {
  final random = Random();
  return _emojiList[random.nextInt(_emojiList.length)];
}

class HouseWorkAddScreen extends ConsumerStatefulWidget {
  const HouseWorkAddScreen({super.key, this.existingHouseWork});

  // 既存の家事から新しい家事を作成するためのファクトリコンストラクタ
  factory HouseWorkAddScreen.fromExistingHouseWork(HouseWork houseWork) {
    return HouseWorkAddScreen(existingHouseWork: houseWork);
  }
  final HouseWork? existingHouseWork;

  @override
  ConsumerState<HouseWorkAddScreen> createState() => _HouseWorkAddScreenState();
}

class _HouseWorkAddScreenState extends ConsumerState<HouseWorkAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  var _icon = '🏠';

  @override
  void initState() {
    super.initState();
    // 既存の家事がある場合は、そのデータを初期値として設定
    if (widget.existingHouseWork != null) {
      final hw = widget.existingHouseWork!;
      _titleController = TextEditingController(text: hw.title);
      _icon = hw.icon;
    } else {
      _titleController = TextEditingController();
      _icon = getRandomEmoji(); // デフォルトでランダムな絵文字を設定
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingHouseWork != null ? '家事を編集' : '家事追加'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコン選択
              Row(
                children: [
                  GestureDetector(
                    onTap: _selectEmoji,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '家事名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '家事名を入力してください';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 登録ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.existingHouseWork != null ? '家事を更新する' : '家事を登録する',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectEmoji() async {
    // 簡易的な絵文字選択ダイアログを表示
    final selectedEmoji = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('アイコンを選択'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _emojiList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(_emojiList[index]),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _emojiList[index],
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );

    if (selectedEmoji != null) {
      setState(() {
        _icon = selectedEmoji;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = ref.read(authServiceProvider).currentUser;

    if (!mounted) {
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ユーザー情報が取得できませんでした')));
      return;
    }

    // 新しい家事を作成
    final houseWork = HouseWork(
      id: widget.existingHouseWork?.id ?? '', // 編集時は既存のID、新規作成時は空文字列
      title: _titleController.text,
      icon: _icon,
      createdAt: widget.existingHouseWork?.createdAt ?? DateTime.now(),
      createdBy: widget.existingHouseWork?.createdBy ?? currentUser.uid,
    );

    try {
      await ref.read(saveHouseWorkResultProvider(houseWork).future);
    } on MaxHouseWorkLimitExceededException {
      if (!mounted) {
        return;
      }

      await _showProUpgradeDialog(
        'フリー版では最大10件までの家事しか登録できません。Pro版にアップグレードすると、無制限に家事を登録できます。',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingHouseWork != null ? '家事を更新しました' : '家事を登録しました',
        ),
      ),
    );

    // 一覧画面に戻る（更新フラグをtrueにして渡す）
    Navigator.of(context).pop(true);
  }

  Future<void> _showProUpgradeDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('制限に達しました'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ProUpgradeScreen(),
                    ),
                  );
                },
                child: const Text('Pro版にアップグレード'),
              ),
            ],
          ),
    );
  }
}
