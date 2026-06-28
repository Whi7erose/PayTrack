import 'package:uuid/uuid.dart';
import '../models/payment_plan.dart';
import '../models/installment.dart';
import 'notification_service.dart';
import '../database/app_database.dart';

class InstallmentGeneratorService {
  static const Uuid _uuid = Uuid();

  static Future<List<Installment>> generateInstallments(PaymentPlan plan) async {
    List<Installment> installments = [];
    DateTime currentDueDate = plan.startDate;

    for (int i = 1; i <= plan.totalPeriods; i++) {
      int notificationId = _uuid.v4().hashCode; // Generate a stable int ID for notifications
      
      Installment installment = Installment(
        id: _uuid.v4(),
        planId: plan.id,
        periodNumber: i,
        dueDate: currentDueDate,
        baseAmount: plan.defaultAmount,
        totalAmount: plan.defaultAmount,
        notificationId: notificationId,
      );

      installments.add(installment);

      // Schedule notification
      _scheduleNotificationForInstallment(plan, installment);

      // Calculate next due date
      currentDueDate = _calculateNextDate(currentDueDate, plan.frequency);
    }

    return installments;
  }

  static Future<void> regenerateNotification(PaymentPlan plan, Installment installment) async {
    if (installment.isPaid) return;
    
    // Cancel old
    await NotificationService.cancelNotification(installment.notificationId);
    // Schedule new
    _scheduleNotificationForInstallment(plan, installment);
  }

  static void _scheduleNotificationForInstallment(PaymentPlan plan, Installment installment) {
    if (installment.isPaid) return;

    DateTime notifyDate = installment.dueDate.subtract(Duration(days: plan.notifyDaysBefore));
    
    // Set to 9 AM if notifyTime is not provided or parse it
    // For simplicity, hardcoded to 9 AM as requested in UI requirement 4
    notifyDate = DateTime(notifyDate.year, notifyDate.month, notifyDate.day, 9, 0);

    NotificationService.scheduleNotification(
      id: installment.notificationId,
      title: 'PayTrack — ${plan.title}',
      body: '${installment.totalAmount} due on ${installment.dueDate.toString().split(' ')[0]}',
      scheduledDate: notifyDate,
    );
  }

  static DateTime _calculateNextDate(DateTime currentDate, String frequency) {
    if (frequency == 'weekly') {
      return currentDate.add(const Duration(days: 7));
    } else if (frequency == 'monthly') {
      int nextMonth = currentDate.month + 1;
      int nextYear = currentDate.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      // Handle edge cases like Jan 31 -> Feb 28
      int nextDay = currentDate.day;
      int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
      if (nextDay > daysInNextMonth) {
        nextDay = daysInNextMonth;
      }
      return DateTime(nextYear, nextMonth, nextDay);
    } else if (frequency == 'annually') {
      return DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
    }
    return currentDate;
  }
}
