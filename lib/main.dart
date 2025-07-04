import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/treasury_provider.dart';
import 'screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/transfer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TreasuryProvider(),
      child: MaterialApp(
        title: 'Treasury Movement',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const DashboardScreen(),
        routes: {
          '/transfer': (context) => const TransferScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
