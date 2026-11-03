import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/inventory_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      debugPrint('Firebase init note: $e');
    }
  }

  runApp(const StockInventoryApp());
}

class StockInventoryApp extends StatelessWidget {
  const StockInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF070B14); // Deepest dark midnight
    const cardBg = Color(0xFF0F172A); // Slate 900
    const primaryCyan = Color(0xFF06B6D4); // Electric Cyan
    const accentIndigo = Color(0xFF6366F1); // Indigo

    return MaterialApp(
      title: 'Stock Inventory Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          secondary: accentIndigo,
          surface: cardBg,
          error: Color(0xFFF43F5E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF070B14),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B1120),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E293B)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1E293B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryCyan, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF43F5E)),
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
      ),
      home: const InventoryScreen(),
    );
  }
}
