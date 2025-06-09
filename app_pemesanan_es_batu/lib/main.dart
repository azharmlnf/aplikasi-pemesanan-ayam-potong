// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

// Import semua halaman dan service Anda
import 'pages/admin/dashboard_page.dart';
import 'pages/customer/dashboard_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'utils/appwrite_constants.dart';

void main() async {
  // Pastikan widget ter-binding sebelum memuat .env
  WidgetsFlutterBinding.ensureInitialized();
  // Muat file .env
  await dotenv.load(fileName: ".env");
  // TAMBAHKAN KODE DEBUG INI
 runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Deklarasikan semua variabel yang akan diinisialisasi
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final AuthService authService;
  late final DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Appwrite Client
    client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true); // Untuk development di localhost, set ke false di produksi

    // Inisialisasi semua service Appwrite
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);

    // Inisialisasi service custom kita dan berikan dependensi yang dibutuhkan
    databaseService = DatabaseService(databases: databases, storage: storage);
    authService = AuthService(account: account, databaseService: databaseService);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pesan Es App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Ganti warna agar lebih segar
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      // Cek status login saat aplikasi pertama kali dibuka
      home: FutureBuilder<models.User?>(
        future: authService.getCurrentUser(),
        builder: (context, snapshot) {
          // Tampilkan loading indicator selagi menunggu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Jika ada data user (berarti sudah login)
          if (snapshot.hasData && snapshot.data != null) {
            // Lanjutkan untuk memeriksa role user
            return FutureBuilder<String?>(
              future: databaseService.getUserRole(snapshot.data!.$id),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                
                // Arahkan ke dashboard yang sesuai berdasarkan role
                if (roleSnapshot.data == 'admin') {
                  return AdminDashboardPage(
                    authService: authService,
                    databaseService: databaseService,
                  );
                } else {
                  // Default ke dashboard customer jika bukan admin atau role tidak ditemukan
                  return CustomerDashboardPage(authService: authService);
                }
              },
            );
          }

          // Jika tidak ada data user, tampilkan halaman login
          return LoginPage(authService: authService, databaseService: databaseService);
        },
      ),
      // Definisikan semua rute aplikasi untuk navigasi
      routes: {
        '/login': (context) => LoginPage(authService: authService, databaseService: databaseService),
        '/register': (context) => RegisterPage(authService: authService),
        '/admin-dashboard': (context) => AdminDashboardPage(
              authService: authService,
              databaseService: databaseService,
            ),
        '/customer-dashboard': (context) => CustomerDashboardPage(authService: authService),
      },
    );
  }
}