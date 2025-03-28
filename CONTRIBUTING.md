# 開発貢献ガイド

このドキュメントでは、House Worker プロジェクトの開発に貢献するための手順を説明します。

## 目次

- [開発環境のセットアップ](#開発環境のセットアップ)
- [初期プロジェクト設定](#初期プロジェクト設定)
- [Emulator の設定](#emulatorの設定)

## 開発環境のセットアップ

### 必要条件

- Flutter SDK
- Firebase CLI
- Android Studio / Xcode（モバイル開発用）

## 初期プロジェクト設定

以下の設定は、プロジェクトの初期構築時に実施した手順です。通常の開発作業では参照する必要はありません。

### Flavor の設定

Flavor を追加する場合は、以下の公式ドキュメントに従ってセットアップしてください。
Xcode 上でスキームの設定を行ってください。

https://docs.flutter.dev/deployment/flavors-ios

### ツールのバージョン固定

Xcode のバージョンを強制するには、以下の手順を実行してください。

https://qiita.com/manicmaniac/items/5294dd16cd6f835ab2d9

### Firebase プロジェクト情報の追加

#### 事前準備

Firebase CLI のインストールとログイン、FlutterFire CLI のインストールが必要です。以下を参照してください。

https://firebase.google.com/docs/flutter/setup?hl=ja&platform=ios#install-cli-tools

#### 環境別の設定更新手順

以下の共通変数を設定します：

```shell
PROJECT_ID_BASE="colomney-house-worker"
APPLICATION_ID_BASE="ide.shota.colomney.HouseWorker"
```

各環境ごとに以下の変数を設定し、共通のコマンドを実行します：

### アイコンの設定

iOS、Android ともに、flutter_launcher_icons ライブラリを利用して生成します。
ライブラリが参照する設定ファイルは、以下の通りです。

- [flutter_launcher_icons-emulator.yaml](client/flutter_launcher_icons-emulator.yaml)
- [flutter_launcher_icons-dev.yaml](client/flutter_launcher_icons-dev.yaml)
- [flutter_launcher_icons-prod.yaml](client/flutter_launcher_icons-prod.yaml)

以下を参考に設定してください。
コマンド実行後 iOS に適用するには、Xcode の"User-Defined Setting"により、構成ごとのアイコン名を定義し、設定する必要があります。

https://pub.dev/packages/flutter_launcher_icons#2-run-the-package

##### Emulator 環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX="-emulator"
APPLICATION_ID_SUFFIX=".emulator"
DART_FILE_NAME_SUFFIX="_emulator"
DIRECTORY_NAME_FOR_IOS="Emulator"
DIRECTORY_NAME_FOR_ANDROID="emulator"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
```

実行時、プロンプトの選択肢では以下を選んでください：

- "Build configuration"
- "Debug-emulator"

##### Dev 環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX="-dev"
APPLICATION_ID_SUFFIX=".dev"
DART_FILE_NAME_SUFFIX="_dev"
DIRECTORY_NAME_FOR_IOS="Dev"
DIRECTORY_NAME_FOR_ANDROID="dev"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
```

実行時、プロンプトの選択肢では以下を選んでください：

- "Build configuration"
- "Debug-dev"

##### Prod 環境の設定

```shell
# 環境固有の変数設定
PROJECT_ID_SUFFIX=""
APPLICATION_ID_SUFFIX=""
DART_FILE_NAME_SUFFIX="_prod"
DIRECTORY_NAME_FOR_IOS="Prod"
DIRECTORY_NAME_FOR_ANDROID="prod"
PROJECT_ID="${PROJECT_ID_BASE}${PROJECT_ID_SUFFIX}"
APPLICATION_ID="${APPLICATION_ID_BASE}${APPLICATION_ID_SUFFIX}"
```

##### 共通のコマンド実行

環境ごとの変数を設定した後、以下の共通コマンドを実行します：

```shell
# Firebaseの設定ファイル生成
cd client/
flutterfire config \
  --project="${PROJECT_ID}" \
  --out="lib/firebase_options${DART_FILE_NAME_SUFFIX}.dart" \
  --ios-bundle-id="${APPLICATION_ID}" \
  --ios-out="ios/Runner/Firebase/${DIRECTORY_NAME_FOR_IOS}/GoogleService-Info.plist" \
  --android-package-name="${APPLICATION_ID}" \
  --android-out="android/app/src/${DIRECTORY_NAME_FOR_ANDROID}/google-services.json"
```

## fastlane の設定

以下を参考に、fastlane を設定します。

https://docs.flutter.dev/deployment/cd#fastlane

## Android のリリースビルドの設定

以下を参考に設定します。

https://docs.flutter.dev/deployment/android#sign-the-app

## Emulator の設定

プロジェクトでは Emulator のホスト IP を`dart-define-from-file`から読み込む方法を採用しています。

### 設定ファイル

プロジェクトには`client/emulator-config.sample.json`というサンプルファイルが含まれています。このファイルをコピーして`client/emulator-config.json`を作成してください。

```shell
# サンプルファイルから設定ファイルを作成
cp client/emulator-config.sample.json client/emulator-config.json
```

作成した`client/emulator-config.json`ファイルには以下の形式で設定が記述されています：

```json
{
  "EMULATOR_HOST": "127.0.0.1"
}
```

必要に応じて`EMULATOR_HOST`の値を変更してください。デフォルト値は`127.0.0.1`です。

> **注意**: `emulator-config.json`は gitignore に設定されており、リポジトリにはコミットされません。各開発者が自分の環境に合わせて設定する必要があります。

### 実行方法

VSCode の起動設定を利用してください。プロジェクトには適切な起動構成が含まれており、自動的に `--dart-define-from-file=client/emulator-config.json` 引数を使用して設定ファイルを読み込みます。

VSCode の「実行とデバッグ」パネルから適切な構成を選択して実行することをお勧めします。
