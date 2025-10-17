import 'package:flutter/material.dart';

// Adjust these imports to your actual file paths.
import '../../ui/live_page.dart';
import '../../ui/lots_page.dart';
import '../../ui/results_page.dart';
import '../dashboard/dashboard_page.dart';
import '../services/pages/services_hub_page.dart';

// If you have a concrete LocaleController in lib/core/locale_controller.dart,
// you can import it. This file does not require the concrete type, but accepts
// any object with a `toggle()` method and (optionally) a `locale` ValueListenable.
import '../../core/locale_controller.dart';

/// Root shell with 5 tabs (Live, Lots, Results, Dashboard, Services).
/// - No dependency on `flutter_gen` or AppLocalizations; labels switch by Locale.
/// - Shows a language toggle button (calls `localeController.toggle()` if present).
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.localeController, // keep this name – your main.dart already uses it
  });

  final Object? localeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Simple translation helper without gen code.
  String _t(BuildContext context, {required String en, required String ar}) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'ar' ? ar : en;
  }

  bool get _isRTL {
    final dir = Directionality.of(context);
    return dir == TextDirection.rtl ||
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
  }

  void _toggleLocaleIfPossible() {
    // We don't know your exact LocaleController API; try common shapes safely.
    final c = widget.localeController;
    try {
      // Method named toggle()
      final dynamic d = c;
      d.toggle();
      return;
    } catch (_) {/* fallthrough */}
    try {
      // Method named switchLocale()
      final dynamic d = c;
      d.switchLocale();
      return;
    } catch (_) {/* fallthrough */}
    // If nothing above works, do nothing (no crash).
    debugPrint(
        'AppShell: localeController missing toggle/switchLocale method.');
  }

  @override
  Widget build(BuildContext context) {
    // Pages – keep them lightweight. Each page can manage its own state/service.
    final pages = const [
      LivePage(),
      LotsPage(),
      ResultsPage(),
      DashboardPage(),
      ServicesHubPage(),
    ];

    final labels = [
      _t(context, en: 'Live', ar: 'مباشر'),
      _t(context, en: 'Lots', ar: 'الخيل'),
      _t(context, en: 'Results', ar: 'النتائج'),
      _t(context, en: 'Dashboard', ar: 'لوحة المتابعة'),
      _t(context, en: 'Services', ar: 'الخدمات'),
    ];

    // Icons – keep system icons to avoid asset issues.
    final icons = const [
      Icons.live_tv,
      Icons.pets, // replace later with your horse-head asset if desired
      Icons.emoji_events,
      Icons.dashboard,
      Icons.home_repair_service,
    ];

    final body = Row(
      children: [
        // Show a NavigationRail only on wide layouts.
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (!wide) return const SizedBox.shrink();
            return NavigationRail(
              selectedIndex: _index,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  tooltip:
                      _t(context, en: 'Toggle language', ar: 'تبديل اللغة'),
                  onPressed: _toggleLocaleIfPossible,
                  icon: const Icon(Icons.translate),
                ),
              ),
              destinations: List.generate(
                pages.length,
                (i) => NavigationRailDestination(
                  icon: Icon(icons[i]),
                  selectedIcon: Icon(icons[i]),
                  label: Text(labels[i]),
                ),
              ),
              onDestinationSelected: (i) => setState(() => _index = i),
            );
          },
        ),
        const VerticalDivider(width: 1),
        Expanded(child: pages[_index]),
      ],
    );

    // For narrow layouts we add a BottomNavigationBar.
    final bottomBar = LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) return const SizedBox.shrink();
        return Directionality(
          textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: BottomNavigationBar(
            currentIndex: _index,
            type: BottomNavigationBarType.fixed,
            onTap: (i) => setState(() => _index = i),
            items: List.generate(
              pages.length,
              (i) => BottomNavigationBarItem(
                icon: Icon(icons[i]),
                label: labels[i],
              ),
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _t(context, en: 'Horse Auctions', ar: 'مزادات الخيول'),
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            tooltip: _t(context, en: 'Toggle language', ar: 'تبديل اللغة'),
            onPressed: _toggleLocaleIfPossible,
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomBar,
    );
  }
}
