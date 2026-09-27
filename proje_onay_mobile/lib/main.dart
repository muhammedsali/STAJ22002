import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/login_screen.dart';
void main() {
  runApp(
    // Riverpod mimarisini projenin tamamında kullanabilmek için ProviderScope ekliyoruz
    const ProviderScope(
      child: TedasApp(),
    ),
  );
}

class TedasApp extends StatelessWidget {
  const TedasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDAŞ Proje Onay',
      debugShowCheckedModeBanner: false, // Sağ üstteki 'DEBUG' yazısını kaldırır
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002244)),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}