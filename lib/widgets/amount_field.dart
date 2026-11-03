import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

/// Large numeric input used for prices, down payment and months.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.suffix,
    this.allowDecimal = true,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final String? suffix;
  final bool allowDecimal;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final allowed = allowDecimal
        ? RegExp(r'[0-9٠-٩۰-۹.,٫٬]')
        : RegExp(r'[0-9٠-٩۰-۹]');

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [FilteringTextInputFormatter.allow(allowed)],
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border(AppColors.border, 1),
        enabledBorder: border(AppColors.border, 1),
        focusedBorder: border(AppColors.charcoal, 2),
        errorBorder: border(AppColors.danger, 1),
        focusedErrorBorder: border(AppColors.danger, 2),
      ),
    );
  }
}
