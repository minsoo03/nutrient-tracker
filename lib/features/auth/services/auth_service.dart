import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상으로 입력해주세요.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'operation-not-allowed':
        return '현재 이메일 회원가입이 비활성화되어 있습니다. Firebase Auth 설정을 확인해주세요.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했습니다. 연결을 확인해주세요.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      default:
        return e.message ?? '인증 처리 중 오류가 발생했습니다. (${e.code})';
    }
  }
}
