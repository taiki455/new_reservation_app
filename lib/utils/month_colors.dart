import 'package:flutter/material.dart';

/// 月ごとのカラーを提供するユーティリティ
/// イベントカードやカレンダーなどで統一したカラーを使用するため
class MonthColors {
  MonthColors._(); // インスタンス化を防ぐ

  /// 月ごとのパステルカラー（背景色）
  static const List<Color> backgroundColors = [
    Color(0xFFE3F2FD), // 1月: 薄い青（冬）
    Color(0xFFFCE4EC), // 2月: 薄いピンク（バレンタイン）
    Color(0xFFF3E5F5), // 3月: 薄い紫（ひな祭り）
    Color(0xFFFFF0F5), // 4月: 桜ピンク
    Color(0xFFE8F5E9), // 5月: 薄い緑（新緑）
    Color(0xFFE0F7FA), // 6月: 薄い水色（梅雨）
    Color(0xFFFFF3E0), // 7月: 薄いオレンジ（夏）
    Color(0xFFFFFDE7), // 8月: 薄い黄色（向日葵）
    Color(0xFFFBE9E7), // 9月: 薄いコーラル（秋の始まり）
    Color(0xFFFFECB3), // 10月: 薄い山吹（紅葉）
    Color(0xFFEFEBE9), // 11月: 薄いベージュ（晩秋）
    Color(0xFFECEFF1), // 12月: 薄いグレー（冬）
  ];

  /// 月ごとのテキストカラー
  static const List<Color> textColors = [
    Color(0xFF1565C0), // 1月: 青
    Color(0xFFC2185B), // 2月: ピンク
    Color(0xFF7B1FA2), // 3月: 紫
    Color(0xFFD81B60), // 4月: 桜色
    Color(0xFF2E7D32), // 5月: 緑
    Color(0xFF00838F), // 6月: シアン
    Color(0xFFEF6C00), // 7月: オレンジ
    Color(0xFFF9A825), // 8月: 黄色
    Color(0xFFD84315), // 9月: コーラル
    Color(0xFFFF8F00), // 10月: 山吹
    Color(0xFF5D4037), // 11月: 茶色
    Color(0xFF455A64), // 12月: グレー
  ];

  /// 月の背景色を取得（1〜12月）
  static Color getBackgroundColor(int month) {
    assert(month >= 1 && month <= 12, '月は1〜12の範囲で指定してください');
    return backgroundColors[month - 1];
  }

  /// 月のテキスト色を取得（1〜12月）
  static Color getTextColor(int month) {
    assert(month >= 1 && month <= 12, '月は1〜12の範囲で指定してください');
    return textColors[month - 1];
  }

  /// 月名を取得（日本語）
  static String getMonthName(int month) {
    const months = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月'
    ];
    return months[month - 1];
  }

  /// DateTimeから月の背景色を取得
  static Color getBackgroundColorFromDate(DateTime date) {
    return getBackgroundColor(date.month);
  }

  /// DateTimeから月のテキスト色を取得
  static Color getTextColorFromDate(DateTime date) {
    return getTextColor(date.month);
  }
}

