// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_appointment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedAppointmentAdapter extends TypeAdapter<SavedAppointment> {
  @override
  final int typeId = 2;

  @override
  SavedAppointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedAppointment(
      id: fields[0] as int,
      serialNumber: fields[1] as int,
      appointmentDate: fields[2] as String,
      appointmentTime: fields[3] as String,
      patientName: fields[4] as String,
      phone: fields[5] as String,
      patientType: fields[6] as String,
      gender: fields[7] as String,
      age: fields[8] as int,
      status: fields[9] as String,
      paymentStatus: fields[10] as String,
      paymentAmount: fields[11] as int,
      location: fields[12] as String?,
      patientId: fields[13] as int?,
      patientPid: fields[14] as String?,
      hasPatientRecord: fields[15] as bool,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
      cachedAt: fields[18] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAppointment obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serialNumber)
      ..writeByte(2)
      ..write(obj.appointmentDate)
      ..writeByte(3)
      ..write(obj.appointmentTime)
      ..writeByte(4)
      ..write(obj.patientName)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.patientType)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.age)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.paymentStatus)
      ..writeByte(11)
      ..write(obj.paymentAmount)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.patientId)
      ..writeByte(14)
      ..write(obj.patientPid)
      ..writeByte(15)
      ..write(obj.hasPatientRecord)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SavedAppointmentStatsAdapter extends TypeAdapter<SavedAppointmentStats> {
  @override
  final int typeId = 3;

  @override
  SavedAppointmentStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedAppointmentStats(
      totalAppointments: fields[0] as int,
      pendingTasks: fields[1] as int,
      completedTask: fields[2] as int,
      cancelledTask: fields[3] as int,
      cachedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedAppointmentStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalAppointments)
      ..writeByte(1)
      ..write(obj.pendingTasks)
      ..writeByte(2)
      ..write(obj.completedTask)
      ..writeByte(3)
      ..write(obj.cancelledTask)
      ..writeByte(4)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAppointmentStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
