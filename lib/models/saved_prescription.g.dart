// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_prescription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedPrescriptionAdapter extends TypeAdapter<SavedPrescription> {
  @override
  final int typeId = 0;

  @override
  SavedPrescription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedPrescription(
      id: fields[0] as String,
      patientName: fields[1] as String,
      patientId: fields[2] as String,
      age: fields[3] as String,
      gender: fields[4] as String,
      phone: fields[5] as String?,
      bloodGroup: fields[6] as String?,
      address: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime?,
      chiefComplaint: fields[10] as String,
      examination: fields[11] as String,
      history: fields[12] as String,
      diagnosis: fields[13] as String,
      investigation: fields[14] as String,
      medicines: (fields[15] as List).cast<SavedMedicine>(),
      adviceList: (fields[16] as List).cast<String>(),
      followUpDate: fields[17] as DateTime?,
      referralText: fields[18] as String?,
      doctorName: fields[19] as String?,
      doctorRegistration: fields[20] as String?,
      doctorSpecialization: fields[21] as String?,
      doctorQualification: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedPrescription obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientName)
      ..writeByte(2)
      ..write(obj.patientId)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.bloodGroup)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.chiefComplaint)
      ..writeByte(11)
      ..write(obj.examination)
      ..writeByte(12)
      ..write(obj.history)
      ..writeByte(13)
      ..write(obj.diagnosis)
      ..writeByte(14)
      ..write(obj.investigation)
      ..writeByte(15)
      ..write(obj.medicines)
      ..writeByte(16)
      ..write(obj.adviceList)
      ..writeByte(17)
      ..write(obj.followUpDate)
      ..writeByte(18)
      ..write(obj.referralText)
      ..writeByte(19)
      ..write(obj.doctorName)
      ..writeByte(20)
      ..write(obj.doctorRegistration)
      ..writeByte(21)
      ..write(obj.doctorSpecialization)
      ..writeByte(22)
      ..write(obj.doctorQualification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPrescriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
