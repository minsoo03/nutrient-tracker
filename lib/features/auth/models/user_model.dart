enum Gender { male, female, other }

enum HealthGoal { diet, muscle, health, medical }

class UserModel {
  final String uid;
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final HealthGoal goal;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyCarbsTarget;
  final int dailyFatTarget;
  final int dailySodiumTarget;
  final bool hasKidneyDisease;
  final bool hasLiverDisease;
  final List<String> medications;
  final DateTime lastWeightUpdatedAt;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.dailyCalorieTarget,
    required this.dailyProteinTarget,
    required this.dailyCarbsTarget,
    required this.dailyFatTarget,
    required this.dailySodiumTarget,
    required this.hasKidneyDisease,
    required this.hasLiverDisease,
    required this.medications,
    required this.lastWeightUpdatedAt,
    required this.createdAt,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> d) {
    final createdAt = _parseDate(d['created_at']) ?? DateTime.now();
    final genderName = d['gender'] as String? ?? Gender.other.name;
    final goalName = d['goal'] as String? ?? HealthGoal.health.name;
    return UserModel(
      uid: d['id'] as String? ?? d['uid'] as String? ?? '',
      name: d['name'] as String? ?? '',
      age: (d['age'] as num?)?.toInt() ?? 0,
      gender: _parseGender(genderName),
      heightCm: (d['height_cm'] as num?)?.toDouble() ?? 0,
      weightKg: (d['weight_kg'] as num?)?.toDouble() ?? 0,
      goal: _parseGoal(goalName),
      dailyCalorieTarget: (d['daily_calorie_target'] as num?)?.toInt() ?? 2000,
      dailyProteinTarget: (d['daily_protein_target'] as num?)?.toInt() ?? 60,
      dailyCarbsTarget: (d['daily_carbs_target'] as num?)?.toInt() ?? 250,
      dailyFatTarget: (d['daily_fat_target'] as num?)?.toInt() ?? 65,
      dailySodiumTarget: (d['daily_sodium_target'] as num?)?.toInt() ?? 2300,
      hasKidneyDisease: d['has_kidney_disease'] as bool? ?? false,
      hasLiverDisease: d['has_liver_disease'] as bool? ?? false,
      medications: List<String>.from(d['medications'] ?? const []),
      lastWeightUpdatedAt: _parseDate(d['last_weight_updated_at']) ?? createdAt,
      createdAt: createdAt,
    );
  }

  static Gender _parseGender(String raw) {
    for (final value in Gender.values) {
      if (value.name == raw) return value;
    }
    return Gender.other;
  }

  static HealthGoal _parseGoal(String raw) {
    for (final value in HealthGoal.values) {
      if (value.name == raw) return value;
    }
    return HealthGoal.health;
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': uid,
      'name': name,
      'age': age,
      'gender': gender.name,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'goal': goal.name,
      'daily_calorie_target': dailyCalorieTarget,
      'daily_protein_target': dailyProteinTarget,
      'daily_carbs_target': dailyCarbsTarget,
      'daily_fat_target': dailyFatTarget,
      'daily_sodium_target': dailySodiumTarget,
      'has_kidney_disease': hasKidneyDisease,
      'has_liver_disease': hasLiverDisease,
      'medications': medications,
      'last_weight_updated_at': lastWeightUpdatedAt.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  UserModel copyWith({
    String? uid,
    String? name,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    HealthGoal? goal,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbsTarget,
    int? dailyFatTarget,
    int? dailySodiumTarget,
    bool? hasKidneyDisease,
    bool? hasLiverDisease,
    List<String>? medications,
    DateTime? lastWeightUpdatedAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
      dailyCarbsTarget: dailyCarbsTarget ?? this.dailyCarbsTarget,
      dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
      dailySodiumTarget: dailySodiumTarget ?? this.dailySodiumTarget,
      hasKidneyDisease: hasKidneyDisease ?? this.hasKidneyDisease,
      hasLiverDisease: hasLiverDisease ?? this.hasLiverDisease,
      medications: medications ?? this.medications,
      lastWeightUpdatedAt: lastWeightUpdatedAt ?? this.lastWeightUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
