import 'package:flutter/material.dart';

/// 단기 복용약 수량 선택 바텀시트
/// 반환: 선택한 수량 (1~99), 취소하면 null
class MedicationDoseSheet extends StatefulWidget {
  final String medicationName;
  final int initialDose;

  const MedicationDoseSheet({
    super.key,
    required this.medicationName,
    this.initialDose = 1,
  });

  static Future<int?> show(
    BuildContext context, {
    required String medicationName,
    int initialDose = 1,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MedicationDoseSheet(
        medicationName: medicationName,
        initialDose: initialDose,
      ),
    );
  }

  @override
  State<MedicationDoseSheet> createState() => _MedicationDoseSheetState();
}

class _MedicationDoseSheetState extends State<MedicationDoseSheet> {
  late int _selected;
  bool _isCustom = false;
  final _customCtrl = TextEditingController();

  static const _quickOptions = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDose;
    if (!_quickOptions.contains(_selected)) {
      _isCustom = true;
      _customCtrl.text = '$_selected';
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_isCustom) {
      final v = int.tryParse(_customCtrl.text.trim());
      if (v != null && v >= 1) Navigator.pop(context, v);
    } else {
      Navigator.pop(context, _selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.medicationName} — 몇 알 드셨나요?',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '복용 수량이 많을수록 간·신장 무리 수치에 더 반영됩니다.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          // 빠른 선택 칩
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._quickOptions.map((n) => ChoiceChip(
                    label: Text('$n알'),
                    selected: !_isCustom && _selected == n,
                    onSelected: (_) => setState(() {
                      _selected = n;
                      _isCustom = false;
                    }),
                  )),
              ChoiceChip(
                label: const Text('직접 입력'),
                selected: _isCustom,
                onSelected: (_) => setState(() => _isCustom = true),
              ),
            ],
          ),
          if (_isCustom) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '수량 입력',
                suffixText: '알',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _confirm,
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
