import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_plan.dart';
import '../models/installment.dart';
import '../providers/payment_plan_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/installment_generator_service.dart';
import 'package:intl/intl.dart';

class CustomizeInstallmentsScreen extends ConsumerStatefulWidget {
  final PaymentPlan plan;
  final List<Installment> initialInstallments;

  const CustomizeInstallmentsScreen({
    Key? key,
    required this.plan,
    required this.initialInstallments,
  }) : super(key: key);

  @override
  ConsumerState<CustomizeInstallmentsScreen> createState() => _CustomizeInstallmentsScreenState();
}

class _CustomizeInstallmentsScreenState extends ConsumerState<CustomizeInstallmentsScreen> {
  late List<Installment> _installments;

  @override
  void initState() {
    super.initState();
    // Create a copy of the installments so we can edit them
    _installments = List.from(widget.initialInstallments);
  }

  void _saveAll() async {
    // Before saving, ensure we recalculate totalAmount
    for (var i in _installments) {
      i.totalAmount = i.baseAmount + i.extraFee;
      
      // Update the notification with the new total amount if it was customized
      // We don't save to DB yet, we let the provider do it, but we need to regenerate
      // the notification text. Actually, the generator already scheduled them.
      // If we change the amount, we should reschedule.
      await InstallmentGeneratorService.regenerateNotification(widget.plan, i);
    }

    await ref.read(paymentPlanProvider.notifier).addPlan(widget.plan, _installments);
    if (!mounted) return;
    Navigator.pop(context); // Go back to dashboard/list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment plan saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Installments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAll,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _installments.length,
        itemBuilder: (context, index) {
          final installment = _installments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Period ${installment.periodNumber} - ${DateFormat.yMMMd().format(installment.dueDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: installment.baseAmount.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Base Amount',
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            setState(() {
                              installment.baseAmount = double.tryParse(v) ?? 0.0;
                              installment.totalAmount = installment.baseAmount + installment.extraFee;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: installment.extraFee.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Extra Fee',
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            setState(() {
                              installment.extraFee = double.tryParse(v) ?? 0.0;
                              installment.totalAmount = installment.baseAmount + installment.extraFee;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Total: '),
                      Text(
                        NumberFormat.currency(symbol: currencySymbol).format(installment.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAll,
        icon: const Icon(Icons.save),
        label: const Text('Save Plan'),
      ),
    );
  }
}
