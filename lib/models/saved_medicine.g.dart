// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMedicineAdapter extends TypeAdapter<SavedMedicine> {
  @override
  final int typeId = 1;

  @override
  SavedMedicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMedicine(
      id: fields[0] as String,
      type: fields[1] as String,
      name: fields[2] as String,
      genericName: fields[3] as String,
      composition: fields[4] as String,
      dosage: fields[5] as String,
      duration: fields[6] as String,
      advice: fields[7] as String,
      route: fields[8] as String,
      specialInstructions: fields[9] as String,
      quantity: fields[10] as String,
      frequency: fields[11] as String,
      interval: fields[12] as String,
      tillNumber: fields[13] as String,
      tillUnit: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMedicine obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.genericName)
      ..writeByte(4)
      ..write(obj.composition)
      ..writeByte(5)
      ..write(obj.dosage)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.advice)
      ..writeByte(8)
      ..write(obj.route)
      ..writeByte(9)
      ..write(obj.specialInstructions)
      ..writeByte(10)
      ..write(obj.quantity)
      ..writeByte(11)
      ..write(obj.frequency)
      ..writeByte(12)
      ..write(obj.interval)
      ..writeByte(13)
      ..write(obj.tillNumber)
      ..writeByte(14)
      ..write(obj.tillUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
