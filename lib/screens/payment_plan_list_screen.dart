import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_plan_provider.dart';
import '../widgets/payment_plan_card.dart';
import 'add_payment_plan_screen.dart';

class PaymentPlanListScreen extends ConsumerWidget {
  const PaymentPlanListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(paymentPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Plans'),
      ),
      body: plans.isEmpty
          ? const Center(
              child: Text('No payment plans found.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return PaymentPlanCard(plan: plans[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPaymentPlanScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
