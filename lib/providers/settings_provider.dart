import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

class SettingsNotifier extends StateNotifier<String> {
  SettingsNotifier() : super(_loadInitialCurrency());

  static String _loadInitialCurrency() {
    return AppDatabase.settingsBox.get('currency', defaultValue: '\$') as String;
  }

  void setCurrency(String symbol) {
    AppDatabase.settingsBox.put('currency', symbol);
    state = symbol;
  }
}

final currencyProvider = StateNotifierProvider<SettingsNotifier, String>((ref) {
  return SettingsNotifier();
});
