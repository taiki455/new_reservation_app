import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

class MyPageScreen extends StatelessWidget {
  final Function(Event) onEventTap;
  final VoidCallback onLogout;

  const MyPageScreen({
    super.key,
    required this.onEventTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // 予約済みイベントを取得
    final reservedEventIds = mockReservations.map((r) => r.eventId).toSet();
    final reservedEvents = mockEvents.where((e) => reservedEventIds.contains(e.eventId)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ヘッダー
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF4DB6AC), // ミントグリーン
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  // ミントグリーンのグラデーション
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4DB6AC), // Teal 300
                      Color(0xFF80CBC4), // Teal 200
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // アバター
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity( 0.2),
                          child: Text(
                            mockCurrentUser.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mockCurrentUser.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mockCurrentUser.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity( 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 統計カード
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.event_available_rounded,
                      label: '予約中',
                      value: '${reservedEvents.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle_rounded,
                      label: '参加済み',
                      value: '8',
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star_rounded,
                      label: 'ポイント',
                      value: '120',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 予約一覧セクション
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '予約中のイベント',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('すべて見る'),
                  ),
                ],
              ),
            ),
          ),
          // 予約一覧
          if (reservedEvents.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '予約中のイベントはありません',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = reservedEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReservationCard(event),
                    );
                  },
                  childCount: reservedEvents.length,
                ),
              ),
            ),
          // メニューセクション
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    '設定',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    label: '通知設定',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'ヘルプ・お問い合わせ',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'アプリについて',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    label: 'ログアウト',
                    onTap: onLogout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Event event) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onEventTap(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // 日付（月ごとにパステルカラー）
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _getMonthColor(event.date.month),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${event.date.month}月',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getMonthTextColor(event.date.month),
                      ),
                    ),
                    Text(
                      '${event.date.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getMonthTextColor(event.date.month),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}〜',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDestructive ? AppColors.error : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 月ごとのパステルカラー（背景色）
  Color _getMonthColor(int month) {
    const monthColors = [
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
    return monthColors[month - 1];
  }

  // 月ごとのテキストカラー
  Color _getMonthTextColor(int month) {
    const textColors = [
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
    return textColors[month - 1];
  }
}

