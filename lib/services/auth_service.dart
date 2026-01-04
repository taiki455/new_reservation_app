import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Firebase Authenticationを使った認証サービス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // コレクション名
  static const String _usersCollection = 'users';

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  /// ログイン状態の変更を監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// メール/パスワードでユーザー登録
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    bool isAdmin = false,
  }) async {
    try {
      // Firebase Authでユーザー作成
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('ユーザー作成に失敗しました');
      }

      // 表示名を設定
      await user.updateDisplayName(name);

      // Firestoreにユーザー情報を保存
      final appUser = AppUser(
        uid: user.uid,
        name: name,
        email: email,
        role: isAdmin ? 'admin' : 'user',
      );

      await _db.collection(_usersCollection).doc(user.uid).set({
        'name': name,
        'email': email,
        'role': isAdmin ? 'admin' : 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // その他のエラー（ネットワークエラーなど）
      throw _handleGenericException(e);
    }
  }

  /// メール/パスワードでログイン
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('ログインに失敗しました');
      }

      // Firestoreからユーザー情報を取得
      final appUser = await getAppUser(user.uid);
      if (appUser == null) {
        // Firestoreにユーザー情報がない場合は作成
        final newUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? 'ユーザー',
          email: email,
          role: 'user',
        );
        await _db.collection(_usersCollection).doc(user.uid).set({
          'name': newUser.name,
          'email': email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return newUser;
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw _handleGenericException(e);
    }
  }

  /// ログアウト
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Firestoreからユーザー情報を取得
  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _db.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  /// 現在のユーザーのAppUserを取得
  Future<AppUser?> getCurrentAppUser() async {
    final user = currentUser;
    if (user == null) return null;
    return getAppUser(user.uid);
  }

  /// ユーザーが管理者かどうか
  Future<bool> isAdmin() async {
    final appUser = await getCurrentAppUser();
    return appUser?.role == 'admin';
  }

  /// パスワードリセットメールを送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw _handleGenericException(e);
    }
  }

  /// ユーザー情報を更新
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? role,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (role != null) updates['role'] = role;

    if (updates.isNotEmpty) {
      await _db.collection(_usersCollection).doc(uid).update(updates);
    }

    // Firebase Authの表示名も更新
    if (name != null && currentUser != null) {
      await currentUser!.updateDisplayName(name);
    }
  }

  /// FirebaseAuthExceptionを日本語メッセージに変換
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // 登録関連
      case 'email-already-in-use':
        return Exception('このメールアドレスは既に使用されています');
      case 'invalid-email':
        return Exception('メールアドレスの形式が正しくありません');
      case 'weak-password':
        return Exception('パスワードは6文字以上で入力してください');
      
      // ログイン関連
      case 'user-not-found':
        return Exception('このメールアドレスは登録されていません');
      case 'wrong-password':
        return Exception('パスワードが間違っています');
      case 'invalid-credential':
        return Exception('メールアドレスまたはパスワードが間違っています');
      case 'user-disabled':
        return Exception('このアカウントは無効化されています');
      
      // 制限関連
      case 'too-many-requests':
        return Exception('ログイン試行回数が多すぎます。しばらく待ってから再度お試しください');
      case 'operation-not-allowed':
        return Exception('この操作は許可されていません');
      
      // ネットワーク関連
      case 'network-request-failed':
        return Exception('ネットワークに接続できません。インターネット接続を確認してください');
      
      // その他
      case 'invalid-verification-code':
        return Exception('認証コードが無効です');
      case 'invalid-verification-id':
        return Exception('認証IDが無効です');
      case 'session-expired':
        return Exception('セッションが切れました。もう一度お試しください');
      case 'quota-exceeded':
        return Exception('リクエスト数が上限に達しました。しばらく待ってから再度お試しください');
      case 'app-not-authorized':
        return Exception('アプリの認証に失敗しました');
      case 'captcha-check-failed':
        return Exception('認証チェックに失敗しました');
      case 'web-context-already-presented':
      case 'web-context-cancelled':
        return Exception('認証がキャンセルされました');
      
      default:
        // エラーコードをログに出力（デバッグ用）
        debugPrint('Unknown FirebaseAuthException code: ${e.code}, message: ${e.message}');
        return Exception('認証エラーが発生しました。もう一度お試しください');
    }
  }

  /// 一般的な例外を日本語メッセージに変換
  Exception _handleGenericException(dynamic e) {
    final errorString = e.toString().toLowerCase();
    
    // ネットワーク関連
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection refused') ||
        errorString.contains('no internet')) {
      return Exception('ネットワークに接続できません。インターネット接続を確認してください');
    }
    
    // タイムアウト
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return Exception('接続がタイムアウトしました。もう一度お試しください');
    }
    
    // Firestore関連
    if (errorString.contains('permission-denied') ||
        errorString.contains('permission denied')) {
      return Exception('アクセス権限がありません');
    }
    
    if (errorString.contains('unavailable')) {
      return Exception('サーバーに接続できません。しばらく待ってから再度お試しください');
    }
    
    // デバッグ用にエラーをログ出力
    debugPrint('Unknown exception: $e');
    return Exception('エラーが発生しました。もう一度お試しください');
  }
}

