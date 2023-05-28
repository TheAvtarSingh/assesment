import 'package:budgetplanner/screens/AddTotalExpenses.dart';
import 'package:budgetplanner/screens/EntryForm.dart';
import 'package:budgetplanner/screens/HomePage.dart';
import 'package:budgetplanner/screens/ManageBudget.dart';
import 'package:budgetplanner/screens/RegisterPage.dart';
import 'package:budgetplanner/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'helper/helper_function.dart';
import 'screens/ExpensesSummaryPage.dart';
import 'screens/FirstScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBthCiaBq3sFpM5V89YV6UJkODMnwObpq4",
            authDomain: "budgetapplication-c5f7c.firebaseapp.com",
            projectId: "budgetapplication-c5f7c",
            storageBucket: "budgetapplication-c5f7c.appspot.com",
            messagingSenderId: "544127178622",
            appId: "1:544127178622:web:7b1537f5b7cc4160b0452f"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Budget Planner",
      initialRoute: _isSignedIn ? '/home' : '/',
      routes: {
        '/': (context) => const FirstScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/entry': (context) => EntryForm(),
        '/manage': (context) => ManageBudget(),
        '/addExpenses': (context) => AddExpensesPage(),
        '/expensesSummary': (context) => ExpensesSummaryPage(),
      },
    );
  }
}
