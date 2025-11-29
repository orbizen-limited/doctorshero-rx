import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure window for desktop
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),  // Fixed window size
    minimumSize: Size(1000, 700),  // Minimum size
    center: true,  // Center on screen
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'DoctorsHero RX',
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
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
