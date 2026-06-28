import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_plan.dart';
import '../database/app_database.dart';
import '../models/installment.dart';

final paymentPlanProvider = StateNotifierProvider<PaymentPlanNotifier, List<PaymentPlan>>((ref) {
  return PaymentPlanNotifier();
});

class PaymentPlanNotifier extends StateNotifier<List<PaymentPlan>> {
  PaymentPlanNotifier() : super([]) {
    loadPlans();
  }

  void loadPlans() {
    state = AppDatabase.getAllPlans();
  }

  Future<void> addPlan(PaymentPlan plan, List<Installment> installments) async {
    await AppDatabase.addPlan(plan);
    await AppDatabase.addInstallments(installments);
    loadPlans();
  }

  Future<void> deletePlan(String planId) async {
    await AppDatabase.deletePlan(planId);
    loadPlans();
  }
}
