import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_plan.dart';
import '../models/installment.dart';

class AppDatabase {
  static const String planBoxName = 'payment_plans';
  static const String installmentBoxName = 'installments';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(PaymentPlanAdapter());
    Hive.registerAdapter(InstallmentAdapter());

    // Open Boxes
    await Hive.openBox<PaymentPlan>(planBoxName);
    await Hive.openBox<Installment>(installmentBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<PaymentPlan> get planBox => Hive.box<PaymentPlan>(planBoxName);
  static Box<Installment> get installmentBox => Hive.box<Installment>(installmentBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  // Plan Methods
  static Future<void> addPlan(PaymentPlan plan) async {
    await planBox.put(plan.id, plan);
  }

  static Future<void> updatePlan(PaymentPlan plan) async {
    await plan.save();
  }

  static Future<void> deletePlan(String planId) async {
    await planBox.delete(planId);
    // Also delete associated installments
    final installmentsToDelete = installmentBox.values.where((i) => i.planId == planId).toList();
    for (var i in installmentsToDelete) {
      await i.delete();
    }
  }

  static List<PaymentPlan> getAllPlans() {
    return planBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Installment Methods
  static Future<void> addInstallment(Installment installment) async {
    await installmentBox.put(installment.id, installment);
  }
  
  static Future<void> addInstallments(List<Installment> installments) async {
    final Map<String, Installment> map = {
      for (var i in installments) i.id: i
    };
    await installmentBox.putAll(map);
  }

  static Future<void> updateInstallment(Installment installment) async {
    await installment.save();
  }

  static List<Installment> getInstallmentsForPlan(String planId) {
    return installmentBox.values.where((i) => i.planId == planId).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  static List<Installment> getAllInstallments() {
    return installmentBox.values.toList();
  }
}
