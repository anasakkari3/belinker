import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';   // تأكد من المسار الصحيح
import 'package:mediator_mvp/start_page/log_in.dart'; // تأكد من المسار الصحيح

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ضروري قبل أي Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BeLinker",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ✅ التبديل التلقائي بين Login و Home حسب حالة المستخدم
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage(); // المستخدم مسجل دخول
          }
          return const LoginScreen(); // مش مسجل دخول
        },
      ),
    );
  }
}
