// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';

// Import semua halaman
import 'pages/splash/splash_page.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/customer/dashboard_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/customer/cart_page.dart';

// Import semua service dan provider
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'providers/cart_provider.dart';
import 'utils/appwrite_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Deklarasikan semua service
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final AuthService authService;
  late final DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua service di satu tempat
    client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);

    databaseService = DatabaseService(databases: databases, storage: storage);
    authService = AuthService(account: account, databaseService: databaseService);
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan MultiProvider untuk menyediakan semua service dan state
    return MultiProvider(
      providers: [
        // Provider untuk state, yang bisa berubah dan memberitahu UI
        ChangeNotifierProvider(create: (ctx) => CartProvider()),

        // Provider untuk service, nilainya tetap (menggunakan .value)
        Provider<AuthService>.value(value: authService),
        Provider<DatabaseService>.value(value: databaseService),
      ],
      child: MaterialApp(
        title: 'Pesan Ayam Potong App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey.shade50, // Latar belakang yang lebih cerah
        ),
        debugShowCheckedModeBanner: false,
        
        // Mulai aplikasi dari splash screen
        initialRoute: '/',
        
        // Definisikan semua rute yang bisa diakses aplikasi
        routes: {
          '/': (context) => const SplashPage(),
          
          // Rute '/home' sebagai titik pengecekan login setelah splash screen
          '/home': (context) => const AuthWrapper(),

          // Rute spesifik untuk setiap halaman
          '/login': (context) => LoginPage(authService: authService, databaseService: databaseService),
          '/register': (context) => RegisterPage(authService: authService),
          '/admin-dashboard': (context) => AdminDashboardPage(authService: authService, databaseService: databaseService),
          '/customer-dashboard': (context) => CustomerDashboardPage(authService: authService, databaseService: databaseService),
          '/cart': (context) => CartPage(authService: authService, databaseService: databaseService),
        },
      ),
    );
  }
}

// Widget pembantu untuk membungkus logika pengecekan login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Akses service menggunakan Provider.of, karena sudah disediakan di atasnya
    final authService = Provider.of<AuthService>(context, listen: false);
    final databaseService = Provider.of<DatabaseService>(context, listen: false);

    return FutureBuilder<models.User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: databaseService.getUserRole(snapshot.data!.$id),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.data == 'admin') {
                return AdminDashboardPage(authService: authService, databaseService: databaseService);
              } else {
                return CustomerDashboardPage(authService: authService, databaseService: databaseService);
              }
            },
          );
        }

        return LoginPage(authService: authService, databaseService: databaseService);
      },
    );
  }
}