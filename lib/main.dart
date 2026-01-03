import 'package:flutter/material.dart';
import 'models/event.dart';
import 'screens/login_screen.dart';
import 'screens/event_list_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/admin/admin_event_list_screen.dart';
import 'screens/admin/event_form_screen.dart';
import 'screens/admin/participants_screen.dart';
import 'screens/admin/csv_import_screen.dart';
import 'theme/app_theme.dart';
import 'data/mock_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'イベント予約',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  void _login({bool asAdmin = false}) {
    setState(() {
      _isLoggedIn = true;
      _isAdmin = asAdmin;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _isAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: (isAdmin) => _login(asAdmin: isAdmin),
      );
    }

    if (_isAdmin) {
      return AdminHomeScreen(onLogout: _logout);
    }

    return UserHomeScreen(onLogout: _logout);
  }
}

// ユーザー用ホーム画面（BottomNavigationBar付き）
class UserHomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const UserHomeScreen({super.key, required this.onLogout});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  Event? _selectedEvent;

  void _showEventDetail(Event event) {
    setState(() {
      _selectedEvent = event;
    });
  }

  void _hideEventDetail() {
    setState(() {
      _selectedEvent = null;
    });
  }

  void _showReservationSuccess() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.accent,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '予約が完了しました！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedEvent?.title}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hideEventDetail();
                },
                child: const Text('OK'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // イベント詳細画面表示中
    if (_selectedEvent != null) {
      return EventDetailScreen(
        event: _selectedEvent!,
        onBack: _hideEventDetail,
        onReserve: _showReservationSuccess,
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          EventListScreen(onEventTap: _showEventDetail),
          MyPageScreen(
            onEventTap: _showEventDetail,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.event_rounded,
                  label: 'イベント',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'マイページ',
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity( 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 管理者用ホーム画面
class AdminHomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminHomeScreen({super.key, required this.onLogout});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _currentScreen = 'list'; // 'list', 'form', 'participants', 'import'
  Event? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'form':
        return EventFormScreen(
          onSave: () => setState(() => _currentScreen = 'list'),
          onCancel: () => setState(() => _currentScreen = 'list'),
        );
      case 'participants':
        return ParticipantsScreen(
          event: _selectedEvent ?? mockEvents.first,
          onBack: () => setState(() => _currentScreen = 'list'),
        );
      case 'import':
        return CsvImportScreen(
          onBack: () => setState(() => _currentScreen = 'list'),
          onImport: (events) {
            // TODO: 実際のインポート処理を実装
            // 今はモックなのでログだけ
            debugPrint('インポートされたイベント: ${events.length}件');
          },
        );
      default:
        return Scaffold(
          body: AdminEventListScreen(
            onEventTap: (event) {
              setState(() {
                _selectedEvent = event;
                _currentScreen = 'participants';
              });
            },
            onCreateEvent: () => setState(() => _currentScreen = 'form'),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // CSVインポートボタン
                    IconButton(
                      onPressed: () => setState(() => _currentScreen = 'import'),
                      icon: const Icon(Icons.file_upload_outlined),
                      tooltip: 'CSVインポート',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.admin_panel_settings, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              '管理者モード',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
