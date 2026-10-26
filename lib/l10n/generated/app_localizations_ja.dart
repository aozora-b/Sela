// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Sela';

  @override
  String get captureModeManual => '手動';

  @override
  String get captureModeInterval => '間隔';

  @override
  String get btnSaveFrame => 'このフレームを保存';

  @override
  String get btnSaveMarked => 'マークした全フレームを保存';

  @override
  String get btnStartExtraction => '抽出を開始';

  @override
  String get intervalCustom => 'カスタム';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds秒';
  }

  @override
  String frameEstimate(int count) {
    return '約$countフレーム';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'フレーム $current / $total';
  }

  @override
  String get errorFailedExtract => 'フレームの取得に失敗しました';

  @override
  String get titleCapture => '抽出';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total フレーム';
  }

  @override
  String progressRemaining(String time) {
    return '残り $time';
  }

  @override
  String get btnCancel => 'キャンセル';

  @override
  String get btnOpenGallery => 'ギャラリーを開く';

  @override
  String get btnClose => '閉じる';

  @override
  String extractionComplete(int count) {
    return '$count枚のフレームをPictures/Selaに保存しました';
  }

  @override
  String extractionCancelled(int count) {
    return '抽出がキャンセルされました。$count枚保存済み。';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return '上限の$maxフレームを超えました。時間を短くするか間隔を広げてください。';
  }

  @override
  String get singleFrameSaved => 'フレームをPictures/Selaに保存しました';

  @override
  String get errorSaveFrame => 'フレームの保存に失敗しました';

  @override
  String get titleExtracting => 'フレームを抽出中...';

  @override
  String get titleHistory => '履歴';

  @override
  String get emptyHistory => '抽出履歴はまだありません';

  @override
  String get dialogResumeTitle => '抽出を再開しますか？';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'フレーム $nextFrame から続行しますか？';
  }

  @override
  String get btnResume => '再開';

  @override
  String get btnRestart => '最初から';

  @override
  String get sessionDeleted => '履歴を削除しました';

  @override
  String historyTotalFrames(int count) {
    return '$countフレーム';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '約$sizeMb MB';
  }

  @override
  String get titleSettings => '設定';

  @override
  String get sectionExtraction => '抽出';

  @override
  String get labelFormat => 'ファイル形式';

  @override
  String get labelJpegQuality => 'JPEG品質';

  @override
  String get sectionAppearance => '外観';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeSystem => 'システム';

  @override
  String get sectionLanguage => '言語';

  @override
  String get titleSelectLanguage => '言語を選択';

  @override
  String get searchLanguage => '言語を検索...';

  @override
  String get sectionSuggested => 'おすすめ';

  @override
  String get sectionAllLanguages => 'すべての言語';

  @override
  String get languageChanged => '言語を変更しました';

  @override
  String get btnUndo => '元に戻す';

  @override
  String get dialogRtlTitle => 'レイアウト方向(RTL)を変更しますか？';

  @override
  String dialogRtlMessage(String language) {
    return '$languageに変更すると、全体のUIレイアウトが反転します。続行しますか？';
  }

  @override
  String get btnApply => '適用';

  @override
  String get sectionAbout => 'アプリについて';

  @override
  String get titleHome => 'ホーム';

  @override
  String get btnPickVideo => '動画を選択';

  @override
  String get homeHeadline => '動画から\n瞬間を切り取る。';

  @override
  String get homeSubtitle => '正確に静止画フレームを抽出します。';

  @override
  String get homePickVideo => '動画を選択';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'フォルダを選択';

  @override
  String get tabExtract => '抽出';

  @override
  String get titleResults => '結果';

  @override
  String get btnSelectAll => 'すべて選択';

  @override
  String get btnDeselectAll => '選択を解除';

  @override
  String get btnSaveToGallery => 'ギャラリーに保存';

  @override
  String get btnShare => '共有';

  @override
  String get btnViewResults => '結果を表示';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$countフレーム · $sizeMb MB';
  }

  @override
  String get folderPickNotice => 'フォルダ選択機能は今後のアップデートで追加されます';

  @override
  String get titleDeleteSession => '履歴を削除';

  @override
  String get confirmDeleteSession => 'この履歴を削除してもよろしいですか？';

  @override
  String get btnDelete => '削除';

  @override
  String get customIntervalTitle => '間隔を設定';

  @override
  String get customIntervalHint => '秒数 (例: 0.1 または 3)';

  @override
  String titlePhotos(int count) {
    return '写真 ($count)';
  }

  @override
  String get resultsSubtitle => 'タップして写真を選択';

  @override
  String get btnSaveAll => 'すべて保存';

  @override
  String get btnSaveSelected => '選択項目を保存';

  @override
  String savedToFolder(int count, String folder) {
    return '$folder に $count 枚保存しました';
  }

  @override
  String get errorSharePhotos => '写真の共有に失敗しました';

  @override
  String get sectionStorage => 'ストレージとフォルダ';

  @override
  String get labelOrganizeByVideo => '動画ごとに整理';

  @override
  String get subOrganizeByVideo => '動画名のサブフォルダを自動作成し、フレームを整理して保存します。';

  @override
  String get labelPickFolder => '保存先フォルダを選択';

  @override
  String get tooltipResetDefault => 'デフォルトに戻す';

  @override
  String storageFolderChanged(String path) {
    return '保存先フォルダを $path に変更しました';
  }

  @override
  String titleSelectVideoCount(int count) {
    return '動画を選択 ($count)';
  }
}
