/// 프로필 입력 검증 결과
class ProfileInputs {
  final int age;
  final double heightCm;
  final double weightKg;

  const ProfileInputs({
    required this.age,
    required this.heightCm,
    required this.weightKg,
  });
}

/// 프로필 폼의 텍스트 입력을 안전하게 파싱·검증
/// - 잘못된 입력은 ProfileInputError로 throw하여 호출부에서 SnackBar로 안내
class ProfileInputError implements Exception {
  final String message;
  const ProfileInputError(this.message);

  @override
  String toString() => message;
}

class ProfileInputValidator {
  /// 텍스트 컨트롤러 raw 값을 받아 (age, heightCm, weightKg) 반환
  /// - 잘못된 형식이거나 합리적 범위를 벗어나면 ProfileInputError throw
  static ProfileInputs parse({
    required String ageText,
    required String heightText,
    required String weightText,
  }) {
    final age = int.tryParse(ageText.trim());
    final heightCm = double.tryParse(heightText.trim());
    final weightKg = double.tryParse(weightText.trim());

    if (age == null || age <= 0 || age > 130) {
      throw const ProfileInputError('나이를 올바르게 입력해주세요 (1~130).');
    }
    if (heightCm == null || heightCm < 50 || heightCm > 250) {
      throw const ProfileInputError('키를 올바르게 입력해주세요 (50~250cm).');
    }
    if (weightKg == null || weightKg < 20 || weightKg > 300) {
      throw const ProfileInputError('몸무게를 올바르게 입력해주세요 (20~300kg).');
    }

    return ProfileInputs(age: age, heightCm: heightCm, weightKg: weightKg);
  }
}
