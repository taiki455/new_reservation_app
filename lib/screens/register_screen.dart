import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // バリデーション
    if (name.isEmpty) {
      _showError('名前を入力してください');
      return;
    }
    if (email.isEmpty) {
      _showError('メールアドレスを入力してください');
      return;
    }
    if (password.isEmpty) {
      _showError('パスワードを入力してください');
      return;
    }
    if (password.length < 6) {
      _showError('パスワードは6文字以上で入力してください');
      return;
    }
    if (password != confirmPassword) {
      _showError('パスワードが一致しません');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アカウントを作成しました！'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onRegisterSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4DB6AC),
              Color(0xFF80CBC4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // ヘッダー
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'アカウント作成',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'イベント予約を始めよう',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // フォーム
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名前
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '名前',
                            hintText: '山田 太郎',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // メールアドレス
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'メールアドレス',
                            hintText: 'example@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // パスワード
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'パスワード',
                            hintText: '6文字以上',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // パスワード確認
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'パスワード（確認）',
                            hintText: '同じパスワードを入力',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 登録ボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'アカウント作成',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ログインへ戻る
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'すでにアカウントをお持ちの方は',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onBackToLogin,
                        child: const Text(
                          'ログイン',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

