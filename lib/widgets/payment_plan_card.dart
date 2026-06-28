import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_plan.dart';
import '../providers/installment_provider.dart';
import '../screens/payment_plan_details_screen.dart';
import '../providers/settings_provider.dart';
import 'package:intl/intl.dart';

class PaymentPlanCard extends ConsumerWidget {
  final PaymentPlan plan;

  const PaymentPlanCard({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installments = ref.watch(installmentProvider(plan.id));
    final currencySymbol = ref.watch(currencyProvider);
    
    // Calculate stats
    final totalInstallments = installments.length;
    final totalAmount = installments.fold<double>(0, (sum, i) => sum + i.totalAmount);
    
    final paidInstallments = installments.where((i) => i.isPaid).toList();
    final unpaidInstallments = installments.where((i) => !i.isPaid).toList();
    
    final ongoing = unpaidInstallments.length; // Simplified definition for now
    
    // Get due this month
    final now = DateTime.now();
    final thisMonthUnpaid = unpaidInstallments.where((i) => 
        i.dueDate.year == now.year && i.dueDate.month == now.month).toList();
        
    final dueThisMonthAmount = thisMonthUnpaid.fold<double>(0, (sum, i) => sum + i.totalAmount);
    
    // Get next payment (first unpaid)
    final nextPaymentAmount = unpaidInstallments.isNotEmpty ? unpaidInstallments.first.totalAmount : 0.0;

    // Use black text for better contrast on pastel colors
    const textColor = Colors.black87;
    const subTextColor = Colors.black54;

    return Card(
      color: Color(plan.colorValue),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentPlanDetailsScreen(plan: plan),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (plan.description != null && plan.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          plan.description!,
                          style: const TextStyle(fontSize: 12, color: subTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDot(Colors.pink.shade300),
                        const SizedBox(width: 4),
                        Text('$ongoing ongoing', style: const TextStyle(fontSize: 12, color: textColor)),
                        const SizedBox(width: 12),
                        _buildDot(Colors.orange.shade300),
                        const SizedBox(width: 4),
                        Text('${paidInstallments.length} done', style: const TextStyle(fontSize: 12, color: textColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalInstallments installments • ${NumberFormat.currency(symbol: currencySymbol).format(totalAmount)}',
                      style: const TextStyle(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ),
              // Right Column
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Due this month', style: TextStyle(fontSize: 10, color: subTextColor)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16, color: subTextColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: currencySymbol).format(dueThisMonthAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next: ${NumberFormat.currency(symbol: currencySymbol).format(nextPaymentAmount)}',
                      style: const TextStyle(fontSize: 10, color: subTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
