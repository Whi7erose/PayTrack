import 'package:hive/hive.dart';
import 'installment.dart';

part 'payment_plan.g.dart';

@HiveType(typeId: 0)
class PaymentPlan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  String frequency; // 'weekly', 'monthly', 'annually'

  @HiveField(5)
  int totalPeriods;

  @HiveField(6)
  double defaultAmount;

  @HiveField(7)
  int notifyDaysBefore;

  @HiveField(8)
  String? notifyTime;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  int colorValue;

  PaymentPlan({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.frequency,
    required this.totalPeriods,
    required this.defaultAmount,
    required this.notifyDaysBefore,
    this.notifyTime,
    required this.createdAt,
    this.colorValue = 0xFFBBDEFB, // Default to a light blue pastel
  });

  bool canUnpayInstallment(Installment installment) {
    if (!installment.isPaid) return false;
    final now = DateTime.now();
    final due = installment.dueDate;

    if (now.isBefore(due)) return true;

    switch (frequency) {
      case 'weekly':
        final daysDiff = now.difference(due).inDays;
        return daysDiff <= 14;
      case 'monthly':
        final monthDiff = (now.year - due.year) * 12 + (now.month - due.month);
        return monthDiff <= 1;
      case 'annually':
        final yearDiff = now.year - due.year;
        return yearDiff <= 1;
      default:
        return true;
    }
  }

  String getUnpayErrorMessage() {
    switch (frequency) {
      case 'weekly':
        return 'Cannot change payment status: payment is older than 1 week.';
      case 'monthly':
        return 'Cannot change payment status: payment is older than 1 month.';
      case 'annually':
        return 'Cannot change payment status: payment is older than 1 year.';
      default:
        return 'Cannot change payment status.';
    }
  }
}
