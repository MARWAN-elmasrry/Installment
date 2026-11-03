import 'package:flutter/material.dart';

import '../models/installment_type.dart';
import '../utils/app_theme.dart';

/// Lets the user pick one of the three installment systems.
class SystemSelector extends StatelessWidget {
  const SystemSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final InstallmentType selected;
  final ValueChanged<InstallmentType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final type in InstallmentType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SystemTile(
              type: type,
              isSelected: type == selected,
              onTap: () => onSelected(type),
            ),
          ),
      ],
    );
  }
}

class _SystemTile extends StatelessWidget {
  const _SystemTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final InstallmentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenLight : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.green : AppColors.mutedText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
