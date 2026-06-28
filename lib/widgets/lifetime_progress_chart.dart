import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';

class LifetimeProgressChart extends ConsumerWidget {
  final double totalPaid;
  final double totalUnpaid;

  const LifetimeProgressChart({
    Key? key,
    required this.totalPaid,
    required this.totalUnpaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(currencyProvider);
    final formatter = NumberFormat.compactCurrency(symbol: currencySymbol);

    double total = totalPaid + totalUnpaid;
    if (total == 0) total = 1;

    final paidRatio = totalPaid / total;
    final unpaidRatio = totalUnpaid / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paid', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                  Text(formatter.format(totalPaid), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                  Text(formatter.format(totalUnpaid), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (paidRatio > 0)
                    Expanded(
                      flex: (paidRatio * 1000).toInt(),
                      child: Container(color: Colors.greenAccent.shade400),
                    ),
                  if (unpaidRatio > 0)
                    Expanded(
                      flex: (unpaidRatio * 1000).toInt(),
                      child: Container(color: Colors.redAccent.shade100),
                    ),
                  if (paidRatio == 0 && unpaidRatio == 0)
                    Expanded(
                      child: Container(color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Total: ${formatter.format(totalPaid + totalUnpaid)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
