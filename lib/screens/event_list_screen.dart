import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../utils/result.dart';

class EventListScreen extends StatefulWidget {
  final Function(Event) onEventTap;

  const EventListScreen({super.key, required this.onEventTap});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _firestoreService = FirestoreService();
  String _selectedFilter = 'すべて';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filterEvents(List<Event> events) {
    var filtered = events.toList();
    final now = DateTime.now();

    // フィルター適用
    switch (_selectedFilter) {
      case '今週':
        final weekEnd = now.add(const Duration(days: 7));
        filtered = filtered.where((e) => e.date.isAfter(now) && e.date.isBefore(weekEnd)).toList();
        break;
      case '今月':
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        filtered = filtered.where((e) => e.date.isAfter(now) && e.date.isBefore(monthEnd)).toList();
        break;
      case '空きあり':
        filtered = filtered.where((e) => !e.isFull && e.date.isAfter(now)).toList();
        break;
    }

    // 検索クエリ適用
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<Event>>(
        stream: _firestoreService.getEvents(),
        builder: (context, snapshot) {
          // ローディング中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'イベントを読み込み中...');
          }

          // エラー
          if (snapshot.hasError) {
            return ErrorView(
              error: AppErrors.custom('イベントの取得に失敗しました'),
              onRetry: () => setState(() {}),
            );
          }

          final allEvents = snapshot.data ?? [];
          final events = _filterEvents(allEvents);

          return CustomScrollView(
            slivers: [
              // ヘッダー
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF4DB6AC),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'イベント一覧',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '参加したいイベントを見つけよう',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 検索バー
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'イベントを検索...',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textHint),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // カテゴリーフィルター
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('すべて'),
                      _buildFilterChip('今週'),
                      _buildFilterChip('今月'),
                      _buildFilterChip('空きあり'),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // 結果件数
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${events.length}件のイベント',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              // イベントリスト
              if (events.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: AppColors.textHint.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          allEvents.isEmpty
                              ? 'イベントがまだありません\n管理者がイベントを作成するとここに表示されます'
                              : '該当するイベントがありません',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                        final event = events[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(
                            event: event,
                            onTap: () => widget.onEventTap(event),
                          ),
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          setState(() => _selectedFilter = label);
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
