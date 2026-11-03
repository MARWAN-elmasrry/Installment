/// The three installment systems found in the Excel file
/// "نظام التقسيط الجديد.xlsx".
enum InstallmentType {
  /// Sheet block 1: one-third down payment, 3% interest per month.
  thirdWithInterest(
    key: 'third_36',
    title: 'نظام تقسيط الثلث بفوايد 36%',
    shortTitle: 'الثلث بفوايد 36%',
    description: 'يُضاف 2000 ج.م لسعر الكاش، وأقل مقدم الثلث، والفائدة 3% عن كل شهر.',
    usesAgreedDownPayment: true,
    monthChoices: [12, 18, 24],
    defaultMonths: 12,
  ),

  /// Sheet block 2: no interest, 6 months, 8% administrative fees.
  sixMonthsNoInterest(
    key: 'six_months_0',
    title: 'نظام تقسيط بدون فوائد على 6 شهور',
    shortTitle: 'بدون فوائد - 6 شهور',
    description: 'يُضاف 1000 ج.م لسعر الكاش، وأقل مقدم النصف، ومصاريف إدارية 8%.',
    usesAgreedDownPayment: false,
    monthChoices: [],
    defaultMonths: 6,
  ),

  /// Sheet block 3: 75% down payment, 3% interest per month on the rest.
  seventyFivePercentDown(
    key: 'down_75',
    title: 'نظام التقسيط بمقدم 75% بدون إضافة',
    shortTitle: 'مقدم 75% بدون إضافة',
    description: 'بدون إضافة على سعر الكاش، وأقل مقدم 75%، والفائدة 3% عن كل شهر.',
    usesAgreedDownPayment: true,
    monthChoices: [],
    defaultMonths: 6,
  );

  const InstallmentType({
    required this.key,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.usesAgreedDownPayment,
    required this.monthChoices,
    required this.defaultMonths,
  });

  /// Stable identifier stored in the local database.
  final String key;
  final String title;
  final String shortTitle;
  final String description;

  /// Whether the user types an "agreed down payment".
  final bool usesAgreedDownPayment;

  /// Fixed month options (empty = no choice list).
  final List<int> monthChoices;
  final int defaultMonths;

  /// True when the number of months is chosen/entered by the user.
  bool get usesMonths => this != InstallmentType.sixMonthsNoInterest;

  static InstallmentType fromKey(String key) {
    return InstallmentType.values.firstWhere(
      (t) => t.key == key,
      orElse: () => InstallmentType.thirdWithInterest,
    );
  }
}
