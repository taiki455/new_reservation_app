import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CsvImportScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(List<Map<String, String>> events) onImport;

  const CsvImportScreen({
    super.key,
    required this.onBack,
    required this.onImport,
  });

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final _csvController = TextEditingController();
  List<Map<String, String>> _previewData = [];
  String? _errorMessage;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  // CSVをパースしてプレビュー表示
  void _parseCSV() {
    setState(() {
      _errorMessage = null;
      _previewData = [];
    });

    final text = _csvController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'CSVデータを入力してください');
      return;
    }

    try {
      final lines = text.split('\n');
      if (lines.length < 2) {
        setState(() => _errorMessage = 'ヘッダー行とデータ行が必要です');
        return;
      }

      // ヘッダー行をパース
      final headers = _parseLine(lines[0]);
      
      // 必須カラムをチェック
      final requiredColumns = ['タイトル', '日付', '場所', '定員'];
      for (final col in requiredColumns) {
        if (!headers.contains(col)) {
          setState(() => _errorMessage = '必須カラム「$col」がありません');
          return;
        }
      }

      // データ行をパース
      final data = <Map<String, String>>[];
      for (var i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        
        final values = _parseLine(lines[i]);
        if (values.length != headers.length) {
          setState(() => _errorMessage = '${i + 1}行目: カラム数が一致しません');
          return;
        }

        final row = <String, String>{};
        for (var j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }
        data.add(row);
      }

      setState(() => _previewData = data);
    } catch (e) {
      setState(() => _errorMessage = 'パースエラー: $e');
    }
  }

  // CSV行をパース（カンマ区切り、ダブルクォート対応）
  List<String> _parseLine(String line) {
    final result = <String>[];
    var current = '';
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current.trim());
    return result;
  }

  void _handleImport() {
    if (_previewData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('インポートするデータがありません'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onImport(_previewData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_previewData.length}件のイベントをインポートしました'),
        backgroundColor: AppColors.success,
      ),
    );
    
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CSVインポート'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 説明カード
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'CSVフォーマット',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1行目: ヘッダー（タイトル,日付,場所,定員,説明）\n'
                    '2行目以降: データ\n\n'
                    '例:\n'
                    'タイトル,日付,場所,定員,説明\n'
                    'フラワーアレンジメント,2026-04-15 14:00,コミュニティセンター,20,春の花を使った...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CSV入力エリア
            const Text(
              'CSVデータを貼り付け',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _csvController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'CSVデータをここに貼り付けてください...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // パースボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _parseCSV,
                icon: const Icon(Icons.preview),
                label: const Text('プレビュー'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // エラーメッセージ
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // プレビュー
            if (_previewData.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'プレビュー（${_previewData.length}件）',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '読み込み成功',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _previewData.length > 5 ? 5 : _previewData.length,
                (index) => _buildPreviewCard(_previewData[index], index + 1),
              ),
              if (_previewData.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '他 ${_previewData.length - 5} 件...',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // インポートボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleImport,
                  icon: const Icon(Icons.file_upload),
                  label: Text('${_previewData.length}件をインポート'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, String> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['タイトル'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data['日付'] ?? ''} / ${data['場所'] ?? ''} / 定員${data['定員'] ?? ''}名',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

