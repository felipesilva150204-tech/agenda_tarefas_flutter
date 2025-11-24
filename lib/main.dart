import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const TarefasApp());
}

/// Aplicativo principal de organização diária de tarefas.
/// Usa tema baseado em um rosa vibrante para dar personalidade ao layout.
class TarefasApp extends StatelessWidget {
  const TarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Organizador Diário',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4081), // rosa vibrante
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
