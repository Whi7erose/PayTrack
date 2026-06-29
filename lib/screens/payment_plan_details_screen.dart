import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_plan.dart';
import '../models/installment.dart';
import '../providers/installment_provider.dart';
import '../providers/payment_plan_provider.dart';
import '../providers/settings_provider.dart';
import 'package:intl/intl.dart';

class PaymentPlanDetailsScreen extends ConsumerStatefulWidget {
  final PaymentPlan plan;

  const PaymentPlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  ConsumerState<PaymentPlanDetailsScreen> createState() => _PaymentPlanDetailsScreenState();
}

class _PaymentPlanDetailsScreenState extends ConsumerState<PaymentPlanDetailsScreen> {
  void _confirmMarkAsPaid(Installment installment) {
    if (installment.isPaid) {
      if (!widget.plan.canUnpayInstallment(installment)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.plan.getUnpayErrorMessage()),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Show confirmation popup for marking as unpaid
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Unpaid'),
          content: const Text('Are you sure you want to mark this payment as unpaid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _togglePaidStatus(installment, showUndo: false);
                },
                child: const Text('Confirm'),
              ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
            'Are you sure you want to mark this payment as paid?\n\n'
            'Plan: ${widget.plan.title}\n'
            'Due Date: ${DateFormat.yMMMd().format(installment.dueDate)}\n'
            'Amount: ${NumberFormat.currency(symbol: ref.read(currencyProvider)).format(installment.totalAmount)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _togglePaidStatus(installment, showUndo: true);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _togglePaidStatus(Installment installment, {bool showUndo = false}) {
    ref.read(installmentProvider(widget.plan.id).notifier).togglePaidStatus(installment, widget.plan);

    if (showUndo) {
      final isNowPaid = installment.isPaid; // the provider toggles it synchronously in the model
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNowPaid ? 'Payment marked as paid' : 'Payment marked as unpaid'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDeletePlan() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to delete this plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(paymentPlanProvider.notifier).deletePlan(widget.plan.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final installments = ref.watch(installmentProvider(widget.plan.id));
    final currencySymbol = ref.watch(currencyProvider);
    int paidCount = installments.where((i) => i.isPaid).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit plan functionality could go here
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeletePlan,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Frequency: ${widget.plan.frequency.toUpperCase()}  |  Progress: $paidCount of ${widget.plan.totalPeriods} paid',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.plan.description != null && widget.plan.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(widget.plan.description!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: installments.length,
              itemBuilder: (context, index) {
                final installment = installments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => _confirmMarkAsPaid(installment),
                    leading: CircleAvatar(
                      backgroundColor: installment.isPaid
                          ? Colors.green.withOpacity(0.2)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        installment.isPaid ? Icons.check : Icons.schedule,
                        color: installment.isPaid ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Period ${installment.periodNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Due: ${DateFormat.yMMMd().format(installment.dueDate)}'),
                        if (installment.isPaid && installment.paidDate != null)
                          Text(
                            'Paid on: ${DateFormat.yMMMd().format(installment.paidDate!)}',
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: currencySymbol).format(installment.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (installment.extraFee > 0)
                          Text(
                            '+ $currencySymbol${installment.extraFee} fee',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
