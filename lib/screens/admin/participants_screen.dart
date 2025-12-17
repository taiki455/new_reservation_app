import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';

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
  late TabController _tabController;
  final Map<String, bool> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 初期化
    for (var participant in mockParticipants) {
      _attendanceMap[participant.uid] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendedCount = _attendanceMap.values.where((v) => v).length;
    
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
      body: Column(
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.event.date.month}月',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity( 0.9),
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
                        '${widget.event.currentParticipants}人予約中 / 定員${widget.event.capacity}人',
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
                _buildParticipantsList(),
                // 出席管理タブ
                _buildAttendanceList(attendedCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockParticipants.length,
      itemBuilder: (context, index) {
        final participant = mockParticipants[index];
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
                backgroundColor: AppColors.primary.withOpacity( 0.1),
                child: Text(
                  participant.name.substring(0, 1),
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
                      participant.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      participant.email,
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
                  _showParticipantOptions(context, participant.name);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList(int attendedCount) {
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
                AppColors.accent.withOpacity( 0.1),
                AppColors.primary.withOpacity( 0.1),
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
                '${mockParticipants.length - attendedCount}',
                AppColors.warning,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              _buildStatItem(
                '出席率',
                '${(attendedCount / mockParticipants.length * 100).toInt()}%',
                AppColors.primary,
              ),
            ],
          ),
        ),
        // リスト
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mockParticipants.length,
            itemBuilder: (context, index) {
              final participant = mockParticipants[index];
              final isAttended = _attendanceMap[participant.uid] ?? false;
              
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
                        ? AppColors.accent.withOpacity( 0.1)
                        : AppColors.surfaceVariant,
                    child: isAttended
                        ? const Icon(Icons.check, color: AppColors.accent)
                        : Text(
                            participant.name.substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                  title: Text(
                    participant.name,
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
                      setState(() {
                        _attendanceMap[participant.uid] = value;
                      });
                    },
                    activeColor: AppColors.accent,
                  ),
                ),
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

  void _showParticipantOptions(BuildContext context, String name) {
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
              leading: const Icon(Icons.email_outlined),
              title: const Text('メールを送信'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: const Text('予約をキャンセル', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

