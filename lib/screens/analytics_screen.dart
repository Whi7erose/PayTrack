import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../providers/payment_plan_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/monthly_progress_chart.dart';
import '../widgets/total_segmented_chart.dart';
import '../widgets/lifetime_progress_chart.dart';
import '../widgets/installments_progress_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final plans = ref.watch(paymentPlanProvider);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChartCard(
              context,
              'Due This Month',
              MonthlyProgressChart(
                paidAmount: dashboardState.thisMonthPaid,
                totalDue: dashboardState.thisMonthTotalDue,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              'Lifetime Paid vs Unpaid',
              LifetimeProgressChart(
                totalPaid: dashboardState.totalPaid,
                totalUnpaid: dashboardState.totalUnpaid,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              'Installments Progress',
              InstallmentsProgressChart(
                paidCount: dashboardState.paidInstallmentsCount,
                unpaidCount: dashboardState.unpaidInstallmentsCount,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              'Total Plans Overview',
              TotalSegmentedChart(
                active: plans.where((p) => p.frequency == 'monthly').length,
                pending: plans.where((p) => p.frequency == 'weekly').length,
                completed: plans.where((p) => p.frequency == 'annually').length,
                totalAmount: dashboardState.totalUnpaid,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Center(child: chart),
          ],
        ),
      ),
    );
  }
}
