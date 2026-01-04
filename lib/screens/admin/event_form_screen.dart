import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // nullなら新規作成、あれば編集
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EventFormScreen({
    super.key,
    this.event,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    // 編集モードの場合は既存のデータを入れる
    if (widget.event != null) {
      _titleController = TextEditingController(text: widget.event!.title);
      _descriptionController = TextEditingController(text: widget.event!.description);
      _locationController = TextEditingController(text: widget.event!.location);
      _capacityController = TextEditingController(text: widget.event!.capacity.toString());
      _selectedDate = widget.event!.date;
      _selectedTime = TimeOfDay(hour: widget.event!.date.hour, minute: widget.event!.date.minute);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _capacityController = TextEditingController(text: '20');
      _selectedDate = DateTime.now().add(const Duration(days: 7));
      _selectedTime = const TimeOfDay(hour: 14, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // バリデーション
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('イベント名を入力してください'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('開催場所を入力してください'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 成功メッセージ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'イベントを更新しました' : 'イベントを作成しました'),
        backgroundColor: AppColors.success,
      ),
    );
    
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'イベント編集' : 'イベント作成'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              '保存',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            _buildSectionTitle('イベント名 *'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '例: 春のBBQパーティー',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            // 日時
            _buildSectionTitle('開催日時 *'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 場所
            _buildSectionTitle('開催場所 *'),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: '例: 代々木公園 BBQエリア',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            // 定員
            _buildSectionTitle('定員 *'),
            const SizedBox(height: 8),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '20',
                prefixIcon: Icon(Icons.people_outline),
                suffixText: '人',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            // 説明
            _buildSectionTitle('イベント説明'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'イベントの詳細を入力してください...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            // プレビューカード
            _buildPreviewCard(),
            const SizedBox(height: 32),
            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'イベントを更新' : 'イベントを作成',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.month}/${_selectedDate.day}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.preview_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'プレビュー',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _titleController.text.isEmpty ? 'イベント名' : _titleController.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleController.text.isEmpty 
                  ? AppColors.textHint 
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${_selectedDate.month}月${_selectedDate.day}日 ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _locationController.text.isEmpty ? '開催場所' : _locationController.text,
                  style: TextStyle(
                    fontSize: 13, 
                    color: _locationController.text.isEmpty 
                        ? AppColors.textHint 
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.people, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '定員 ${_capacityController.text}人',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
