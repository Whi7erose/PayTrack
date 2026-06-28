import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_plan.dart';
import '../models/installment.dart';
import '../database/app_database.dart';
import 'payment_plan_provider.dart';

class DashboardState {
  final int activePlans;
  final int upcomingPayments;
  final int overduePayments;
  final int dueToday;
  final double totalPaid;
  final double totalUnpaid;
  final double thisMonthTotalDue;
  final double thisMonthPaid;
  final int totalInstallmentsCount;
  final int paidInstallmentsCount;
  final int unpaidInstallmentsCount;

  DashboardState({
    required this.activePlans,
    required this.upcomingPayments,
    required this.overduePayments,
    required this.dueToday,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.thisMonthTotalDue,
    required this.thisMonthPaid,
    required this.totalInstallmentsCount,
    required this.paidInstallmentsCount,
    required this.unpaidInstallmentsCount,
  });

  factory DashboardState.initial() => DashboardState(
        activePlans: 0,
        upcomingPayments: 0,
        overduePayments: 0,
        dueToday: 0,
        totalPaid: 0,
        totalUnpaid: 0,
        thisMonthTotalDue: 0,
        thisMonthPaid: 0,
        totalInstallmentsCount: 0,
        paidInstallmentsCount: 0,
        unpaidInstallmentsCount: 0,
      );
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  // Listen to payment plan changes to refresh dashboard
  ref.watch(paymentPlanProvider);
  return DashboardNotifier()..loadDashboard();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState.initial());

  void loadDashboard() {
    final plans = AppDatabase.getAllPlans();
    final installments = AppDatabase.getAllInstallments();

    int activePlans = plans.length;
    int upcoming = 0;
    int overdue = 0;
    int dueTodayCount = 0;
    double paid = 0;
    double unpaid = 0;
    double thisMonthDue = 0;
    double thisMonthPaid = 0;
    int totalCount = installments.length;
    int paidCount = 0;
    int unpaidCount = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i in installments) {
      if (i.dueDate.year == now.year && i.dueDate.month == now.month) {
        thisMonthDue += i.totalAmount;
        if (i.isPaid) {
          thisMonthPaid += i.totalAmount;
        }
      }

      if (i.isPaid) {
        paid += i.totalAmount;
        paidCount++;
      } else {
        unpaid += i.totalAmount;
        unpaidCount++;
        
        final iDate = DateTime(i.dueDate.year, i.dueDate.month, i.dueDate.day);
        
        if (iDate.isBefore(today)) {
          overdue++;
        } else if (iDate.isAtSameMomentAs(today)) {
          dueTodayCount++;
        } else {
          upcoming++;
        }
      }
    }

    state = DashboardState(
      activePlans: activePlans,
      upcomingPayments: upcoming,
      overduePayments: overdue,
      dueToday: dueTodayCount,
      totalPaid: paid,
      totalUnpaid: unpaid,
      thisMonthTotalDue: thisMonthDue,
      thisMonthPaid: thisMonthPaid,
      totalInstallmentsCount: totalCount,
      paidInstallmentsCount: paidCount,
      unpaidInstallmentsCount: unpaidCount,
    );
  }
}
