import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'home_page.dart'; // role selection
import 'auth/login_page.dart'; // login page
import 'explorer_user/ExplorerHome.dart'; // explorer home
import 'organizer/organizer_dashboard_page.dart'; // organizer dashboard
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EventifyApp());
}

class EventifyApp extends StatelessWidget {
  const EventifyApp({super.key});

  // Future to initialize Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eventify Ethiopia',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            elevation: 0,
          ),
        ),
        home: FutureBuilder<FirebaseApp>(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            // Firebase initialization loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              );
            }

            // Firebase initialization error
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error initializing Firebase: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            // Firebase initialized successfully
            return SplashScreen();
          },
        ),
        routes: {
          '/home': (context) => HomePage(), // role selection
          '/explorer': (context) => ExploreHome(),
          '/organizer': (context) => OrganizerDashboardPage(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with arguments (e.g., login page with role)
          if (settings.name == '/login') {
            final args = settings.arguments as Map<String, String>?;
            final role = args?['role'] ?? '';
            return MaterialPageRoute(
              builder: (context) => LoginPage(role: role),
            );
          }
          return null;
        },
      ),
    );
  }
}
