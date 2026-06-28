import 'package:hive/hive.dart';

part 'installment.g.dart';

@HiveType(typeId: 1)
class Installment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String planId;

  @HiveField(2)
  int periodNumber;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  double baseAmount;

  @HiveField(5)
  double extraFee;

  @HiveField(6)
  double totalAmount;

  @HiveField(7)
  String? note;

  @HiveField(8)
  bool isPaid;

  @HiveField(9)
  DateTime? paidDate;

  @HiveField(10)
  int notificationId;

  Installment({
    required this.id,
    required this.planId,
    required this.periodNumber,
    required this.dueDate,
    required this.baseAmount,
    this.extraFee = 0,
    required this.totalAmount,
    this.note,
    this.isPaid = false,
    this.paidDate,
    required this.notificationId,
  });
}
