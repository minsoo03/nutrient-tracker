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
  final bool hasKidneyDisease;
  final bool hasLiverDisease;
  final List<String> medications;
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
    required this.hasKidneyDisease,
    required this.hasLiverDisease,
    required this.medications,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String,
      age: data['age'] as int,
      gender: Gender.values.byName(data['gender'] as String),
      heightCm: (data['heightCm'] as num).toDouble(),
      weightKg: (data['weightKg'] as num).toDouble(),
      goal: HealthGoal.values.byName(data['goal'] as String),
      dailyCalorieTarget: data['dailyCalorieTarget'] as int,
      dailyProteinTarget: data['dailyProteinTarget'] as int,
      hasKidneyDisease: data['hasKidneyDisease'] as bool,
      hasLiverDisease: data['hasLiverDisease'] as bool,
      medications: List<String>.from(data['medications'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
      'hasKidneyDisease': hasKidneyDisease,
      'hasLiverDisease': hasLiverDisease,
      'medications': medications,
      'createdAt': Timestamp.fromDate(createdAt),
    };
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
    bool? hasKidneyDisease,
    bool? hasLiverDisease,
    List<String>? medications,
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
      hasKidneyDisease: hasKidneyDisease ?? this.hasKidneyDisease,
      hasLiverDisease: hasLiverDisease ?? this.hasLiverDisease,
      medications: medications ?? this.medications,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
