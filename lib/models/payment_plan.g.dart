// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentPlanAdapter extends TypeAdapter<PaymentPlan> {
  @override
  final int typeId = 0;

  @override
  PaymentPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentPlan(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      startDate: fields[3] as DateTime,
      frequency: fields[4] as String,
      totalPeriods: fields[5] as int,
      defaultAmount: fields[6] as double,
      notifyDaysBefore: fields[7] as int,
      notifyTime: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      colorValue: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentPlan obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.totalPeriods)
      ..writeByte(6)
      ..write(obj.defaultAmount)
      ..writeByte(7)
      ..write(obj.notifyDaysBefore)
      ..writeByte(8)
      ..write(obj.notifyTime)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
