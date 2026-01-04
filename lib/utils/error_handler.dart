import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'result.dart';

/// エラーハンドリングのユーティリティクラス
class ErrorHandler {
  /// SnackBarでエラーを表示
  static void showError(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(error.userMessage)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// SnackBarで成功を表示
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// SnackBarで情報を表示
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// エラーダイアログを表示
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Text(title ?? 'エラー'),
          ],
        ),
        content: Text(error.userMessage),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('再試行'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 非同期処理をラップしてエラーハンドリング
  static Future<Result<T>> tryAsync<T>(
    Future<T> Function() action, {
    AppError? fallbackError,
  }) async {
    try {
      final result = await action();
      return Success(result);
    } catch (e) {
      // エラーの種類によって適切なAppErrorを返す
      final error = _mapException(e, fallbackError);
      debugPrint('Error: $e');
      return Failure(error);
    }
  }

  /// 同期処理をラップしてエラーハンドリング
  static Result<T> trySync<T>(
    T Function() action, {
    AppError? fallbackError,
  }) {
    try {
      final result = action();
      return Success(result);
    } catch (e) {
      final error = _mapException(e, fallbackError);
      debugPrint('Error: $e');
      return Failure(error);
    }
  }

  /// 例外をAppErrorにマッピング
  static AppError _mapException(dynamic e, AppError? fallback) {
    // ネットワークエラーの判定（実際のアプリではSocketExceptionなどをチェック）
    if (e.toString().contains('SocketException') ||
        e.toString().contains('NetworkException')) {
      return AppErrors.network;
    }

    // タイムアウトの判定
    if (e.toString().contains('TimeoutException')) {
      return AppErrors.timeout;
    }

    // フォールバックエラーがあればそれを返す
    if (fallback != null) {
      return AppError(
        message: fallback.message,
        code: fallback.code,
        originalError: e,
      );
    }

    // それ以外は不明なエラー
    return AppError(
      message: AppErrors.unknown.message,
      code: AppErrors.unknown.code,
      originalError: e,
    );
  }
}

