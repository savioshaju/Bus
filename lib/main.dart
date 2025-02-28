import 'dart:io';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'transit_provider.dart';
import 'login.dart' as login;
import 'newreg.dart';
import 'searchpage.dart' as search;
import 'admin.dart';
import 'admin_approval.dart';
import 'pending_approval.dart';
import 'profile_page.dart';
import 'ChangePasswordPage.dart';
import 'BusOwnerDetailsPage.dart' as b;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const login.LoginPage(),
        '/homepage': (context) => const HomePage(),
        '/transit_provider': (context) => const TransitProviderPage(),
        '/signup': (context) => const SignUpPage(),
        '/searchpage': (context) => const search.SearchPage(),
        '/newreg': (context) => const SignUpPage(),
        '/admin': (context) => const AdminPage(),
        '/admin_approval': (context) => const AdminApprovalPage(),
        '/pending_approval': (context) => const PendingApprovalPage(),
        '/profile': (context) => ProfilePage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/bus_owner_details': (context) => b.BusOwnerDetailsPage(),
      },
    );
  }
}
