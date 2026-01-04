import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      case 'email-already-in-use':
        return Exception('このメールアドレスは既に使用されています');
      case 'invalid-email':
        return Exception('メールアドレスの形式が正しくありません');
      case 'weak-password':
        return Exception('パスワードは6文字以上で入力してください');
      case 'user-not-found':
        return Exception('このメールアドレスは登録されていません');
      case 'wrong-password':
        return Exception('パスワードが間違っています');
      case 'too-many-requests':
        return Exception('しばらく時間をおいてから再度お試しください');
      case 'user-disabled':
        return Exception('このアカウントは無効化されています');
      case 'operation-not-allowed':
        return Exception('この操作は許可されていません');
      default:
        return Exception('エラーが発生しました: ${e.message}');
    }
  }
}

