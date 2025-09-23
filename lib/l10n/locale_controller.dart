import 'package:flutter/widgets.dart';

class LocaleController extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  /// Convenience lookup used inside the UI, e.g. `LocaleController.maybeOf(context)?.setLocale(...)`.
  static LocaleController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LocaleHost>()?.controller;
}

class LocaleControllerProvider extends StatefulWidget {
  final LocaleController controller;
  final Widget child;
  const LocaleControllerProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<LocaleControllerProvider> createState() =>
      _LocaleControllerProviderState();
}

class _LocaleControllerProviderState extends State<LocaleControllerProvider> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return _LocaleHost(controller: widget.controller, child: widget.child);
  }
}

class _LocaleHost extends InheritedWidget {
  final LocaleController controller;
  const _LocaleHost({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _LocaleHost oldWidget) =>
      oldWidget.controller != controller;
}
