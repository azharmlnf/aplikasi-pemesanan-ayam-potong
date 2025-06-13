import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'database_service.dart';

class AuthService {
  final Account account;
  final DatabaseService databaseService;

  AuthService({required this.account, required this.databaseService});

  // Fungsi untuk mendapatkan pengguna yang sedang login
  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } on AppwriteException {
      return null;
    }
  }

  // Fungsi Registrasi YANG DIPERBAIKI
  Future<models.User?> register({
    required String email,
    required String password,
    required String username,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Langkah 1: Buat akun di Appwrite Auth (sama seperti sebelumnya)
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: username,
      );

      // LANGKAH BARU YANG KRUSIAL: LANGSUNG LOGIN SETELAH REGISTRASI
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Langkah 2: Buat dokumen di collection 'profiles'
      // Sekarang aksi ini dilakukan oleh PENGGUNA YANG SUDAH LOGIN
      await databaseService.createProfile(
        userId: user.$id,
        username: username,
        name: name,
        phoneNumber: phoneNumber,
      );

      return user;
    } on AppwriteException catch (e) {
      print('Gagal Registrasi: ${e.message}');
      rethrow;
    }
  }

  // Fungsi Login
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      return await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      print('Gagal Login: ${e.message}');
      rethrow;
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      print('Gagal Logout: ${e.message}');
    }
  }
}