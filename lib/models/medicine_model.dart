class Medicine {
  final String id;
  final String type; // Tab., Cap., Syp., Inj., Susp., Drops
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
    );
  }
}
