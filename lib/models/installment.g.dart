// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstallmentAdapter extends TypeAdapter<Installment> {
  @override
  final int typeId = 1;

  @override
  Installment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Installment(
      id: fields[0] as String,
      planId: fields[1] as String,
      periodNumber: fields[2] as int,
      dueDate: fields[3] as DateTime,
      baseAmount: fields[4] as double,
      extraFee: fields[5] as double,
      totalAmount: fields[6] as double,
      note: fields[7] as String?,
      isPaid: fields[8] as bool,
      paidDate: fields[9] as DateTime?,
      notificationId: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Installment obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.periodNumber)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.baseAmount)
      ..writeByte(5)
      ..write(obj.extraFee)
      ..writeByte(6)
      ..write(obj.totalAmount)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.isPaid)
      ..writeByte(9)
      ..write(obj.paidDate)
      ..writeByte(10)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
