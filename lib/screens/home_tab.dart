import 'package:flutter/material.dart';

import '../models/installment_type.dart';
import '../utils/app_theme.dart';
import '../widgets/app_card.dart';

/// Landing tab: business name and shortcuts to the three systems.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenSystem});

  final ValueChanged<InstallmentType> onOpenSystem;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset('assets/images/app_icon.png',
                    width: 84, height: 84),
              ),
              const SizedBox(height: 14),
              const Text(
                'مؤسسة مصر مباشر',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'حاسبة التقسيط',
                style: TextStyle(fontSize: 16, color: AppColors.mutedText),
              ),
              const SizedBox(height: 12),
              const Text(
                'تعمل بدون إنترنت، وجميع الحسابات والسجل محفوظة على الجهاز فقط.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'اختر نظام التقسيط',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal),
        ),
        const SizedBox(height: 10),
        for (final type in InstallmentType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onOpenSystem(type),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            type.description,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_left, color: AppColors.green),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
