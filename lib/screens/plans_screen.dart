import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_plan_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/payment_plan_card.dart';
import 'add_payment_plan_screen.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(paymentPlanProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: plans.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No payment plans yet. Create one!'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
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
