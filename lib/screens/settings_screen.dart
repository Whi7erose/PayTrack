import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> _currencies = [
    {'name': 'US Dollar', 'symbol': '\$'},
    {'name': 'Euro', 'symbol': '€'},
    {'name': 'British Pound', 'symbol': '£'},
    {'name': 'Japanese Yen', 'symbol': '¥'},
    {'name': 'Indian Rupee', 'symbol': '₹'},
    {'name': 'Sri Lankan Rupee', 'symbol': 'LKR '},
    {'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'name': 'Swiss Franc', 'symbol': 'CHF '},
    {'name': 'Chinese Yuan', 'symbol': 'CN¥'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._currencies.map((currency) {
            final isSelected = currentCurrency == currency['symbol'];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  currency['symbol']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(currency['name']!),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency(currency['symbol']!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
