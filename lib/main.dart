// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously, unused_element, unused_field, depend_on_referenced_packages, prefer_final_fields, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/friend_requests_screen.dart';
import 'screens/friends_screen.dart';
// import 'utils/init_friends_field.dart'; // Ya no es necesario

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await initializeFriendsFieldForAllUsers(); // Línea eliminada
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fútbol App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigation(),
        '/friend_requests': (context) => const FriendRequestsScreen(),
        '/friends': (context) => const FriendsScreen(),
      },
    );
  }
}
