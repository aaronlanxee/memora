
import 'package:flutter/material.dart';
import 'package:memora/api_service.dart';
import 'package:memora/base/navbar.dart';
import 'package:memora/screens/login.dart';
import 'package:memora/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiService.setupSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memora',
      debugShowCheckedModeBanner: false,
      theme: memoraTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> sessionCheck;

  @override
  void initState() {
    super.initState();
    sessionCheck = ApiService.checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: sessionCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const NavBar();
        }

        return const LoginScreen();
      },
    );
  }
}
