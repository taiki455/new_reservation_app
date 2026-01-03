import 'package:flutter/material.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日付カード（月ごとに色が変わる）
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _getMonthColor(event.date.month),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getMonth(event.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getMonthTextColor(event.date.month),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          event.date.day.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            color: _getMonthTextColor(event.date.month),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // イベント情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(event.date),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 参加者状況バー
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: event.currentParticipants / event.capacity,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              event.isFull ? AppColors.error : AppColors.accent,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.currentParticipants}/${event.capacity}人',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (event.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '満席',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '残り${event.remainingSpots}席',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
    );
  }

  String _getMonth(DateTime date) {
    const months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return months[date.month - 1];
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

