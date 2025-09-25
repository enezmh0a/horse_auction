import 'package:flutter/material.dart';

/// Simple locale controller + scope (no persistence).
class LocaleController extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  /// Set app locale (null = follow system).
  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  /// Convenience so you can write: LocaleController.of(context)
  static LocaleController of(BuildContext context) =>
      LocaleControllerScope.of(context);
}

/// Inherited notifier to expose the controller down the tree.
class LocaleControllerScope extends InheritedNotifier<LocaleController> {
  const LocaleControllerScope({
    super.key,
    required LocaleController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static LocaleController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleControllerScope>();
    assert(scope != null, 'LocaleControllerScope not found in context');
    return scope!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<LocaleController> old) {
    return notifier != old.notifier;
  }
}
