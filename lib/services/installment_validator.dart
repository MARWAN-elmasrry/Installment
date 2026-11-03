import '../models/installment_type.dart';
import '../utils/formatters.dart';
import 'installment_calculator.dart';

/// Form validation with Arabic messages. Each method returns null when the
/// input is valid, or the message to show.
class InstallmentValidator {
  InstallmentValidator._();

  /// Upper limit for a free-typed number of months (system 3).
  static const int maxFreeMonths = 60;

  static String? cashPrice(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'من فضلك أدخل سعر الكاش';
    }
    final value = parseAmount(text);
    if (value == null) return 'سعر الكاش غير صحيح';
    if (value <= 0) return 'سعر الكاش يجب أن يكون أكبر من صفر';
    return null;
  }

  static String? downPayment(
    String? text, {
    required InstallmentType type,
    required String? cashText,
  }) {
    if (text == null || text.trim().isEmpty) {
      return 'من فضلك أدخل المقدم المتفق عليه';
    }
    final value = parseAmount(text);
    if (value == null) return 'المقدم المتفق عليه غير صحيح';
    if (value < 0) return 'المقدم لا يمكن أن يكون سالبًا';

    final cash = parseAmount(cashText);
    if (cash != null && cash > 0) {
      final limit = InstallmentCalculator.adjustedPrice(type, cash);
      if (value > limit) {
        return type == InstallmentType.seventyFivePercentDown
            ? 'المقدم لا يمكن أن يزيد عن سعر الكاش (${formatMoney(limit)})'
            : 'المقدم لا يمكن أن يزيد عن السعر بعد الإضافة (${formatMoney(limit)})';
      }
    }
    return null;
  }

  static String? months(String? text, {required InstallmentType type}) {
    if (text == null || text.trim().isEmpty) {
      return 'من فضلك أدخل عدد الأشهر';
    }
    final value = parseWholeNumber(text);
    if (value == null) return 'عدد الأشهر يجب أن يكون رقمًا صحيحًا';
    if (type.monthChoices.isNotEmpty) {
      if (!type.monthChoices.contains(value)) {
        return 'اختر عدد أشهر صحيح (${type.monthChoices.join(' / ')})';
      }
      return null;
    }
    if (value < 1 || value > maxFreeMonths) {
      return 'عدد الأشهر يجب أن يكون بين 1 و $maxFreeMonths';
    }
    return null;
  }
}
