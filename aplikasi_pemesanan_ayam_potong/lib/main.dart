// lib/main.dart (VERSI YANG BENAR)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';

import 'pages/admin/dashboard_page.dart';
import 'pages/customer/dashboard_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'utils/appwrite_constants.dart';
import 'providers/cart_provider.dart';
import 'pages/customer/cart_page.dart'; // <-- 1. IMPORT HALAMAN KERANJANG


// <<< 1. BUAT GLOBAL KEY DI SINI, DI LUAR CLASS >>>
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


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
  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  late final AuthService authService;
  late final DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);

    databaseService = DatabaseService(databases: databases, storage: storage);
    authService = AuthService(
      account: account,
      databaseService: databaseService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(
         // <<< 2. PASANG KUNCI GLOBAL KE MATERIALAPP >>>
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Pesan Ayam Potong App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<models.User?>(
          future: authService.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              return FutureBuilder<String?>(
                future: databaseService.getUserRole(snapshot.data!.$id),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (roleSnapshot.data == 'admin') {
                    return AdminDashboardPage(
                      authService: authService,
                      databaseService: databaseService,
                    );
                  } else {
                    return CustomerDashboardPage(
                      authService: authService,
                      databaseService: databaseService,
                    );
                  }
                },
              );
            }

            return LoginPage(
              authService: authService,
              databaseService: databaseService,
            );
          },
        ),
        routes: {
          '/login': (context) => LoginPage(
            authService: authService,
            databaseService: databaseService,
          ),
          '/register': (context) => RegisterPage(authService: authService),
          '/admin-dashboard': (context) => AdminDashboardPage(
            authService: authService,
            databaseService: databaseService,
          ),
          '/customer-dashboard': (context) => CustomerDashboardPage(
            authService: authService,
            databaseService: databaseService,
          ),
          // --- 2. TAMBAHKAN RUTE BARU DI SINI ---
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}
