import 'package:flutter/material.dart';

import '../models/installment_type.dart';
import '../utils/app_theme.dart';
import 'calculator_tab.dart';
import 'history_tab.dart';
import 'home_tab.dart';

/// The single main Scaffold with bottom navigation between the 3 sections.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _titles = ['الرئيسية', 'حاسبة التقسيط', 'سجل العمليات'];

  int _index = 0;
  InstallmentType _type = InstallmentType.thirdWithInterest;
  final ValueNotifier<int> _historyVersion = ValueNotifier<int>(0);

  @override
  void dispose() {
    _historyVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        centerTitle: true,
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      // IndexedStack keeps each tab's state (typed values, results) alive.
      body: IndexedStack(
        index: _index,
        children: [
          HomeTab(
            onOpenSystem: (type) => setState(() {
              _type = type;
              _index = 1;
            }),
          ),
          CalculatorTab(
            type: _type,
            onTypeChanged: (type) => setState(() => _type = type),
            onSaved: () => _historyVersion.value++,
          ),
          HistoryTab(refresh: _historyVersion),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.greenLight,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'حاسبة التقسيط'),
          NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'سجل العمليات'),
        ],
      ),
    );
  }
}
