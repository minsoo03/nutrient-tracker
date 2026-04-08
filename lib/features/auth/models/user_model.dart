import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    final createdAt =
        (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final genderName = d['gender'] as String? ?? Gender.other.name;
    final goalName = d['goal'] as String? ?? HealthGoal.health.name;
    return UserModel(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      age: (d['age'] as num?)?.toInt() ?? 0,
      gender: Gender.values.byName(genderName),
      heightCm: (d['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (d['weightKg'] as num?)?.toDouble() ?? 0,
      goal: HealthGoal.values.byName(goalName),
      dailyCalorieTarget: (d['dailyCalorieTarget'] as num?)?.toInt() ?? 2000,
      dailyProteinTarget: (d['dailyProteinTarget'] as num?)?.toInt() ?? 60,
      dailyCarbsTarget: (d['dailyCarbsTarget'] as num?)?.toInt() ?? 250,
      dailyFatTarget: (d['dailyFatTarget'] as num?)?.toInt() ?? 65,
      dailySodiumTarget: (d['dailySodiumTarget'] as num?)?.toInt() ?? 2300,
      hasKidneyDisease: d['hasKidneyDisease'] as bool? ?? false,
      hasLiverDisease: d['hasLiverDisease'] as bool? ?? false,
      medications: List<String>.from(d['medications'] ?? const []),
      lastWeightUpdatedAt:
          (d['lastWeightUpdatedAt'] as Timestamp?)?.toDate() ??
          createdAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender.name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': goal.name,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyProteinTarget': dailyProteinTarget,
      'dailyCarbsTarget': dailyCarbsTarget,
      'dailyFatTarget': dailyFatTarget,
      'dailySodiumTarget': dailySodiumTarget,
      'hasKidneyDisease': hasKidneyDisease,
      'hasLiverDisease': hasLiverDisease,
      'medications': medications,
      'lastWeightUpdatedAt': Timestamp.fromDate(lastWeightUpdatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid, String? name, int? age, Gender? gender,
    double? heightCm, double? weightKg, HealthGoal? goal,
    int? dailyCalorieTarget, int? dailyProteinTarget,
    int? dailyCarbsTarget, int? dailyFatTarget, int? dailySodiumTarget,
    bool? hasKidneyDisease, bool? hasLiverDisease,
    List<String>? medications, DateTime? lastWeightUpdatedAt, DateTime? createdAt,
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
