import 'package:flutter/material.dart';

import '../models/history_record.dart';
import '../services/history_database.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';

/// History tab: saved calculations stored locally (SQLite).
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key, required this.refresh});

  /// Incremented by the shell each time a calculation is saved.
  final ValueNotifier<int> refresh;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<HistoryRecord> _records = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    widget.refresh.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await HistoryDatabase.instance.all();
      if (!mounted) return;
      setState(() {
        _records = data;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<bool> _confirm(String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action,
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _deleteOne(HistoryRecord record) async {
    final id = record.id;
    if (id == null) return;
    if (!await _confirm('هل تريد حذف هذه العملية؟', 'حذف')) return;
    await HistoryDatabase.instance.delete(id);
    await _load();
  }

  Future<void> _deleteAll() async {
    if (!await _confirm('هل تريد حذف كل العمليات المحفوظة؟', 'حذف الكل')) {
      return;
    }
    await HistoryDatabase.instance.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return const Center(child: Text('تعذر قراءة السجل'));
    }
    if (_records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'لا توجد عمليات محفوظة بعد.\nاحسب تقسيطًا واضغط "حفظ العملية".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.mutedText),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'عدد العمليات: ${_records.length}',
                style: const TextStyle(
                    fontSize: 15, color: AppColors.mutedText),
              ),
            ),
            TextButton.icon(
              onPressed: _deleteAll,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              label: const Text('حذف الكل',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
        for (final record in _records)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HistoryCard(
              record: record,
              onDelete: () => _deleteOne(record),
            ),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.onDelete});

  final HistoryRecord record;
  final VoidCallback onDelete;

  Widget _line(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.mutedText)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: strong ? AppColors.green : AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.type.shortTitle,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal),
                ),
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon:
                    const Icon(Icons.delete_outline, color: AppColors.danger),
              ),
            ],
          ),
          Text(formatDateTime(record.createdAt),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedText)),
          const SizedBox(height: 8),
          _line('سعر الكاش', formatCurrency(record.cashPrice)),
          _line('المقدم', formatCurrency(record.downPayment)),
          _line('عدد الأشهر', '${record.months}'),
          _line('القسط الشهري', formatCurrency(record.monthlyInstallment),
              strong: true),
          _line('الإجمالي', formatCurrency(record.totalAmount), strong: true),
        ],
      ),
    );
  }
}
