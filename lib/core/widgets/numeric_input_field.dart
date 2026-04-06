import 'package:flutter/material.dart';

class NumericInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? suffixText;
  final String? hintText;
  final String? helperText;
  final bool allowDecimal;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const NumericInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.suffixText,
    this.hintText,
    this.helperText,
    this.allowDecimal = true,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      autofocus: autofocus,
      onTap: () => _openNumberPad(context),
      decoration: InputDecoration(
        labelText: labelText,
        suffixText: suffixText,
        hintText: hintText,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Future<void> _openNumberPad(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _NumberPadSheet(
        initialValue: controller.text,
        allowDecimal: allowDecimal,
        labelText: labelText,
      ),
    );

    if (result == null) return;
    controller.text = result;
    onChanged?.call(result);
  }
}

class _NumberPadSheet extends StatefulWidget {
  final String initialValue;
  final bool allowDecimal;
  final String labelText;

  const _NumberPadSheet({
    required this.initialValue,
    required this.allowDecimal,
    required this.labelText,
  });

  @override
  State<_NumberPadSheet> createState() => _NumberPadSheetState();
}

class _NumberPadSheetState extends State<_NumberPadSheet> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.labelText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _value),
                  child: const Text('완료'),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _value.isEmpty ? '0' : _value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _padRow(['1', '2', '3']),
            _padRow(['4', '5', '6']),
            _padRow(['7', '8', '9']),
            _padRow([
              widget.allowDecimal ? '.' : '지움',
              '0',
              '⌫',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _padRow(List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: values
            .map(
              (value) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilledButton(
                    onPressed: () => _handleTap(value),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(value, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handleTap(String value) {
    setState(() {
      switch (value) {
        case '⌫':
          if (_value.isNotEmpty) {
            _value = _value.substring(0, _value.length - 1);
          }
          break;
        case '지움':
          _value = '';
          break;
        case '.':
          if (widget.allowDecimal && !_value.contains('.')) {
            _value = _value.isEmpty ? '0.' : '$_value.';
          }
          break;
        default:
          _value = '$_value$value';
      }
    });
  }
}
