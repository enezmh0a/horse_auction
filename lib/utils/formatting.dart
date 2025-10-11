import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

NumberFormat currencyFor(BuildContext context) => NumberFormat.simpleCurrency(
  locale: Localizations.localeOf(context).toString(),
);

String money(BuildContext context, num value) =>
    currencyFor(context).format(value);
