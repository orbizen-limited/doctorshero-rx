import 'package:hive/hive.dart';
import 'medicine_model.dart';

part 'saved_medicine.g.dart';

@HiveType(typeId: 1)
class SavedMedicine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // Tab., Cap., Syp., Inj., Susp., Drops, Spray

  @HiveField(2)
  String name;

  @HiveField(3)
  String genericName;

  @HiveField(4)
  String composition;

  @HiveField(5)
  String dosage;

  @HiveField(6)
  String duration;

  @HiveField(7)
  String advice;

  @HiveField(8)
  String route; // For Inj: SC, IM, IV, etc.

  @HiveField(9)
  String specialInstructions;

  @HiveField(10)
  String quantity;

  @HiveField(11)
  String frequency;

  @HiveField(12)
  String interval;

  @HiveField(13)
  String tillNumber;

  @HiveField(14)
  String tillUnit;

  SavedMedicine({
    required this.id,
    required this.type,
    required this.name,
    required this.genericName,
    required this.composition,
    required this.dosage,
    required this.duration,
    required this.advice,
    this.route = '',
    this.specialInstructions = '',
    this.quantity = '',
    this.frequency = '',
    this.interval = '',
    this.tillNumber = '',
    this.tillUnit = '',
  });

  // Convert from Medicine model
  factory SavedMedicine.fromMedicine(Medicine medicine) {
    return SavedMedicine(
      id: medicine.id,
      type: medicine.type,
      name: medicine.name,
      genericName: medicine.genericName,
      composition: medicine.composition,
      dosage: medicine.dosage,
      duration: medicine.duration,
      advice: medicine.advice,
      route: medicine.route,
      specialInstructions: medicine.specialInstructions,
      quantity: medicine.quantity,
      frequency: medicine.frequency,
      interval: medicine.interval,
      tillNumber: medicine.tillNumber,
      tillUnit: medicine.tillUnit,
    );
  }

  // Convert to Medicine model
  Medicine toMedicine() {
    return Medicine(
      id: id,
      type: type,
      name: name,
      genericName: genericName,
      composition: composition,
      dosage: dosage,
      duration: duration,
      advice: advice,
      route: route,
      specialInstructions: specialInstructions,
      quantity: quantity,
      frequency: frequency,
      interval: interval,
      tillNumber: tillNumber,
      tillUnit: tillUnit,
    );
  }
}
