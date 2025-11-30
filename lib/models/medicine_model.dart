class Medicine {
  final String id;
  final String type; // Tab., Cap., Syp., Inj., Susp., Drops, Spray
  final String name;
  final String genericName;
  final String composition;
  final String dosage;
  final String duration;
  final String advice;
  final String route; // For Inj: SC, IM, IV, etc.
  final String specialInstructions; // For Spray: "per nostril", "both nostrils", etc.
  final String quantity; // For Inj/Spray: "1 Capsule", "1 Ampoule", etc.
  final String frequency; // For Inj/Spray: "1 Time", "2 Times", etc.
  final String interval; // Optional: "Por Por", "Daily", etc.
  final String tillNumber; // Optional: When to stop - number
  final String tillUnit; // Optional: When to stop - unit (Days, Weeks, etc.)

  Medicine({
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

  String get fullName => '$type $name';

  Medicine copyWith({
    String? id,
    String? type,
    String? name,
    String? genericName,
    String? composition,
    String? dosage,
    String? duration,
    String? advice,
    String? route,
    String? specialInstructions,
    String? quantity,
    String? frequency,
    String? interval,
    String? tillNumber,
    String? tillUnit,
  }) {
    return Medicine(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      composition: composition ?? this.composition,
      dosage: dosage ?? this.dosage,
      duration: duration ?? this.duration,
      advice: advice ?? this.advice,
      route: route ?? this.route,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      quantity: quantity ?? this.quantity,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      tillNumber: tillNumber ?? this.tillNumber,
      tillUnit: tillUnit ?? this.tillUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'generic_name': genericName,
      'composition': composition,
      'dosage': dosage,
      'duration': duration,
      'advice': advice,
      'route': route,
      'special_instructions': specialInstructions,
      'quantity': quantity,
      'frequency': frequency,
      'interval': interval,
      'till_number': tillNumber,
      'till_unit': tillUnit,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'Tab.',
      name: json['name'] ?? '',
      genericName: json['generic_name'] ?? '',
      composition: json['composition'] ?? '',
      dosage: json['dosage'] ?? '',
      duration: json['duration'] ?? '',
      advice: json['advice'] ?? '',
      route: json['route'] ?? '',
      specialInstructions: json['special_instructions'] ?? '',
      quantity: json['quantity'] ?? '',
      frequency: json['frequency'] ?? '',
      interval: json['interval'] ?? '',
      tillNumber: json['till_number'] ?? '',
      tillUnit: json['till_unit'] ?? '',
    );
  }
}
