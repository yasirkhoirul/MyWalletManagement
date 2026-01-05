import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

/// Custom exception wrapper that normalizes Firebase Auth errors
/// and other error objects into a predictable message + code.
class CustomFirebaseException implements Exception {
  final Object original;
  final bool isFirebaseAuthError;
  final String code;
  final String message;

  const CustomFirebaseException._(
    this.original,
    this.isFirebaseAuthError,
    this.code,
    this.message,
  );

  /// Create a [CustomFirebaseException] from any error object.
  ///
  /// If the object is a [FirebaseAuthException] the factory will map
  /// known `code` values to friendly messages. If not, it will try
  /// to read `code` and `message` dynamically; otherwise it falls
  /// back to `error.toString()`.
  factory CustomFirebaseException(Object error) {
    if (error is FirebaseAuthException) {
      final code = error.code;
      final msg = _mapFirebaseAuthCodeToMessage(code) ?? error.message ?? 'Terjadi kesalahan autentikasi.';
      return CustomFirebaseException._(error, true, code, msg);
    }

    // Try dynamic access for objects that mimic FirebaseAuthException
    try {
      final dynamic e = error;
      final String? code = e.code as String?;
      final String? msg = e.message as String?;
      if (code != null) {
        final mapped = _mapFirebaseAuthCodeToMessage(code) ?? msg ?? 'Terjadi kesalahan.';
        return CustomFirebaseException._(error, true, code, mapped);
      }
    } catch (_) {
      // ignore: no-op
    }

    return CustomFirebaseException._(error, false, 'unknown', error.toString());
  }

  /// Map common Firebase Auth error codes to user-friendly messages.
  static String? _mapFirebaseAuthCodeToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email tidak valid.';
      case 'user-disabled':
        return 'Akun pengguna dinonaktifkan.';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'operation-not-allowed':
        return 'Operasi ini tidak diizinkan.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Gagal koneksi jaringan.';
      case 'requires-recent-login':
        return 'Perlu login ulang untuk operasi ini.';
      case 'invalid-credential':
        return 'Kredensial tidak valid.';
      case 'account-exists-with-different-credential':
        return 'Akun sudah ada dengan kredensial berbeda.';
      default:
        return null;
    }
  }

  @override
  String toString() => 'CustomFirebaseException(code: $code, message: $message)';
}