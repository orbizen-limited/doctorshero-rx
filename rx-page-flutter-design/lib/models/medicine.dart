class Medicine {
  final String id;
  final String type; // Tab., Cap., Syp., etc.
  final String name;
  final String genericName;
  final String composition;
  final String dosage;
  final String duration;
  final String advice;

  Medicine({
    required this.id,
    required this.type,
    required this.name,
    required this.genericName,
    required this.composition,
    required this.dosage,
    required this.duration,
    required this.advice,
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
    );
  }
}
