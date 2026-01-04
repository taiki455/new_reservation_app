/// 処理結果を表すResult型
/// 成功時はSuccess、失敗時はFailureを返す
sealed class Result<T> {
  const Result();

  /// 成功かどうか
  bool get isSuccess => this is Success<T>;

  /// 失敗かどうか
  bool get isFailure => this is Failure<T>;

  /// 成功時の値を取得（失敗時はnull）
  T? get valueOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).value;
    }
    return null;
  }

  /// エラーを取得（成功時はnull）
  AppError? get errorOrNull {
    if (this is Failure<T>) {
      return (this as Failure<T>).error;
    }
    return null;
  }

  /// 成功時と失敗時で処理を分岐
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).value);
    } else {
      return failure((this as Failure<T>).error);
    }
  }
}

/// 成功を表すクラス
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// 失敗を表すクラス
class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

/// アプリ内で使用するエラー型
class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  /// ユーザー向けメッセージを取得
  String get userMessage => message;

  @override
  String toString() => 'AppError: $message (code: $code)';
}

/// よく使うエラーの定義
class AppErrors {
  static const network = AppError(
    message: 'ネットワークに接続できません',
    code: 'NETWORK_ERROR',
  );

  static const server = AppError(
    message: 'サーバーエラーが発生しました',
    code: 'SERVER_ERROR',
  );

  static const timeout = AppError(
    message: '接続がタイムアウトしました',
    code: 'TIMEOUT_ERROR',
  );

  static const unauthorized = AppError(
    message: 'ログインが必要です',
    code: 'UNAUTHORIZED',
  );

  static const notFound = AppError(
    message: 'データが見つかりません',
    code: 'NOT_FOUND',
  );

  static const validation = AppError(
    message: '入力内容に誤りがあります',
    code: 'VALIDATION_ERROR',
  );

  static const unknown = AppError(
    message: '予期せぬエラーが発生しました',
    code: 'UNKNOWN_ERROR',
  );

  /// カスタムエラーを作成
  static AppError custom(String message, {String? code}) {
    return AppError(message: message, code: code);
  }
}

