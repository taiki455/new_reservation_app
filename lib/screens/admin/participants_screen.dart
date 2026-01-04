import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/reservation.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// 参加者情報（予約情報 + ユーザー情報）
class ParticipantInfo {
  final Reservation reservation;
  final String name;
  final String email;

  ParticipantInfo({
    required this.reservation,
    required this.name,
    required this.email,
  });
}

class ParticipantsScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onBack;

  const ParticipantsScreen({
    super.key,
    required this.event,
    required this.onBack,
  });

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 出席状態を更新
  Future<void> _updateAttendance(String reservationId, bool attended) async {
    try {
      await _firestoreService.updateAttendance(reservationId, attended);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 予約をキャンセル
  Future<void> _cancelReservation(Reservation reservation, String participantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約をキャンセル'),
        content: Text('$participantNameさんの予約をキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('キャンセルする'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.cancelReservation(reservation.reservationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$participantNameさんの予約をキャンセルしました'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('キャンセルに失敗しました: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('参加者管理'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '参加者一覧'),
            Tab(text: '出席管理'),
          ],
        ),
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: _firestoreService.getEventReservations(widget.event.eventId),
        builder: (context, snapshot) {
          final reservations = snapshot.data ?? [];
          final attendedCount = reservations.where((r) => r.attended).length;

          return Column(
            children: [
              // イベント情報サマリー
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.event.date.month}月',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            '${widget.event.date.day}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                            widget.event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reservations.length}人予約中 / 定員${widget.event.capacity}人',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // タブコンテンツ
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 参加者一覧タブ
                    _buildParticipantsList(reservations),
                    // 出席管理タブ
                    _buildAttendanceList(reservations, attendedCount),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticipantsList(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16),
            Text(
              '参加者はまだいません',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        // ユーザー名はreservationから取得（Firestoreに保存されている場合）
        // ない場合はユーザーIDの先頭を表示
        final displayName = 'ユーザー ${index + 1}';
        final displayEmail = '${reservation.userId.substring(0, 8)}...@user';
        
        return FutureBuilder<ParticipantInfo?>(
          future: _getParticipantInfo(reservation),
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? displayName;
            final email = snapshot.data?.email ?? displayEmail;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textHint),
                    onPressed: () {
                      _showParticipantOptions(context, reservation, name);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Firestoreからユーザー情報を取得
  Future<ParticipantInfo?> _getParticipantInfo(Reservation reservation) async {
    try {
      // usersコレクションからユーザー情報を取得
      final userDoc = await _firestoreService.getUserInfo(reservation.userId);
      if (userDoc != null) {
        return ParticipantInfo(
          reservation: reservation,
          name: userDoc['name'] ?? 'ユーザー',
          email: userDoc['email'] ?? '',
        );
      }
    } catch (e) {
      debugPrint('Failed to get user info: $e');
    }
    return null;
  }

  Widget _buildAttendanceList(List<Reservation> reservations, int attendedCount) {
    final totalCount = reservations.length;
    final attendanceRate = totalCount > 0 ? (attendedCount / totalCount * 100).toInt() : 0;

    return Column(
      children: [
        // 出席統計
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '出席済み',
                '$attendedCount',
                AppColors.accent,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              _buildStatItem(
                '未出席',
                '${totalCount - attendedCount}',
                AppColors.warning,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              _buildStatItem(
                '出席率',
                '$attendanceRate%',
                AppColors.primary,
              ),
            ],
          ),
        ),
        // リスト
        if (reservations.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                '参加者はまだいません',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                final isAttended = reservation.attended;
                
                return FutureBuilder<ParticipantInfo?>(
                  future: _getParticipantInfo(reservation),
                  builder: (context, snapshot) {
                    final name = snapshot.data?.name ?? 'ユーザー ${index + 1}';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAttended ? AppColors.accent : AppColors.divider,
                          width: isAttended ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: isAttended 
                              ? AppColors.accent.withOpacity(0.1)
                              : AppColors.surfaceVariant,
                          child: isAttended
                              ? const Icon(Icons.check, color: AppColors.accent)
                              : Text(
                                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isAttended ? AppColors.accent : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          isAttended ? '出席済み' : '未出席',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAttended ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                        trailing: Switch(
                          value: isAttended,
                          onChanged: (value) {
                            _updateAttendance(reservation.reservationId, value);
                          },
                          activeColor: AppColors.accent,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
    );
  }

  void _showParticipantOptions(BuildContext context, Reservation reservation, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: const Text('予約をキャンセル', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _cancelReservation(reservation, name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
