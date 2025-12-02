import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediator_mvp/app_widgets/MainScreen.dart';
import 'package:mediator_mvp/firebase_options.dart';
import 'home_page.dart';
import 'package:mediator_mvp/start_page/log_in.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // مهم جدًا: لازم يكون في user قبل أي قراءة/كتابة
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  debugPrint('✅ uid: ${FirebaseAuth.instance.currentUser!.uid}');

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
        // 👇 هي المهمّة
        textTheme: GoogleFonts.interTextTheme(),
        // ولو بدك ألوان مخصصة كمان:
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0057D9),
        ),
        useMaterial3: true,
      ),
      // ✅ التبديل التلقائي بين Login و Home حسب حالة المستخدم
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainScreen(); // المستخدم مسجل دخول
          }
          return const LoginScreen(); // مش مسجل دخول
        },
      ),
    );
  }
}
