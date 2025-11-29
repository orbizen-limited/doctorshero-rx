import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'DoctorsHero RX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'ProductSans',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFE3001),
            primary: const Color(0xFFFE3001),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
