import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
  Locale get locale => Localizations.localeOf(this);
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
