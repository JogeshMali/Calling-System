import 'package:calling_system/firebase/firebase_service.dart';
import 'package:calling_system/pages/signin_page.dart';
import 'package:calling_system/service_locator.dart';
import 'package:flutter/material.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await FirebaseService.initialize();
await initializeDependency();
runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calling System',
      debugShowCheckedModeBanner: false,     
      theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 126, 32)),
        useMaterial3: true,
      ),
      home: SigninPage()
    );
  }
}