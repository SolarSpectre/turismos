import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '',
    anonKey: '',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touristic Sites',
      theme: ThemeData(
        primaryColor: Color(0xFF1976D2),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1976D2),
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF26C6DA), // teal accent
          background: Color(0xFFF5F5F5),
          surface: Color(0xFFE3F2FD),
          error: Color(0xFFE53935), // lively red
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFE53935), // use red for text buttons
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF26C6DA),
          foregroundColor: Colors.white,
        ),
        cardColor: Color(0xFFE3F2FD),
        iconTheme: IconThemeData(color: Color(0xFF1976D2)),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}