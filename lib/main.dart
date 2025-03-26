import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messagerie_instantanee/firebase_options.dart';
import 'package:messagerie_instantanee/services/auth/auth_gate.dart';
import 'package:messagerie_instantanee/services/auth/auth_service.dart';
import 'package:messagerie_instantanee/services/database/database_provider.dart';
import 'package:messagerie_instantanee/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AuthGate(),
    );
  }
}
