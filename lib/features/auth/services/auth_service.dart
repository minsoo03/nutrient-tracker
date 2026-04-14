import 'package:nutrient_tracker/features/auth/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _client.from('profiles').upsert(user.toSupabase());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    return UserModel.fromSupabase(row);
  }

  String _authErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (message.contains('email') && message.contains('invalid')) {
      return '이메일 형식이 올바르지 않습니다.';
    }
    if (message.contains('already') || message.contains('registered')) {
      return '이미 사용 중인 이메일입니다.';
    }
    if (message.contains('password')) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }
    return e.message;
  }
}
