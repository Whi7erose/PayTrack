import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/installment.dart';
import '../models/payment_plan.dart';
import '../database/app_database.dart';
import '../services/installment_generator_service.dart';
import 'payment_plan_provider.dart';
import 'dashboard_provider.dart';

final installmentProvider = StateNotifierProvider.family<InstallmentNotifier, List<Installment>, String>((ref, planId) {
  return InstallmentNotifier(planId, ref);
});

class InstallmentNotifier extends StateNotifier<List<Installment>> {
  final String planId;
  final Ref ref;

  InstallmentNotifier(this.planId, this.ref) : super([]) {
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
    ref.invalidate(dashboardProvider);
  }

  Future<void> updateInstallment(Installment installment, PaymentPlan plan) async {
    await AppDatabase.updateInstallment(installment);
    await InstallmentGeneratorService.regenerateNotification(plan, installment);
    loadInstallments();
    ref.invalidate(dashboardProvider);
  }
}
