import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installment.dart';
import '../models/payment_plan.dart';
import '../database/app_database.dart';
import '../services/installment_generator_service.dart';
import 'payment_plan_provider.dart';

final installmentProvider = StateNotifierProvider.family<InstallmentNotifier, List<Installment>, String>((ref, planId) {
  return InstallmentNotifier(planId);
});

class InstallmentNotifier extends StateNotifier<List<Installment>> {
  final String planId;

  InstallmentNotifier(this.planId) : super([]) {
    loadInstallments();
  }

  void loadInstallments() {
    state = AppDatabase.getInstallmentsForPlan(planId);
  }

  Future<void> togglePaidStatus(Installment installment, PaymentPlan plan) async {
    installment.isPaid = !installment.isPaid;
    installment.paidDate = installment.isPaid ? DateTime.now() : null;
    
    await AppDatabase.updateInstallment(installment);
    
    // Regenerate or cancel notification based on new status
    await InstallmentGeneratorService.regenerateNotification(plan, installment);
    
    loadInstallments();
  }

  Future<void> updateInstallment(Installment installment, PaymentPlan plan) async {
    await AppDatabase.updateInstallment(installment);
    await InstallmentGeneratorService.regenerateNotification(plan, installment);
    loadInstallments();
  }
}
