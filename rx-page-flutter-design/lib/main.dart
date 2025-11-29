import 'package:flutter/material.dart';
import 'screens/prescription_screen.dart';

void main() {
  runApp(const MedicalPrescriptionApp());
}

class MedicalPrescriptionApp extends StatelessWidget {
  const MedicalPrescriptionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Prescription',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: 'SF Pro Display',
      ),
      home: const PrescriptionScreen(),
    );
  }
}
