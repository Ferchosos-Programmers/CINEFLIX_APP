import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cineflix/screens/Login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Cineflix());
}

class Cineflix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData.dark(),
      home: Principal(),
    );
  }
}

class Principal extends StatefulWidget {
  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Login(),
    );
  }
}
