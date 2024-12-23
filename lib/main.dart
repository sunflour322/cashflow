import 'package:cashflow/back/auth_service/user_service.dart';
import 'package:cashflow/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyBKakS4dzfbmsFSCP4NzN9eZ6SDLSeCcvo',
        appId: '1:874539196455:android:e0b90b6e7b41dc1e472e02',
        messagingSenderId: '874539196455',
        projectId: 'flutter-films-mukachev',
        storageBucket: 'flutter-films-mukachev.appspot.com'),
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
        initialData: null,
        value: AuthService().currentUser,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CashFlow',
          initialRoute: '/',
          routes: routes,
        ));
  }
}
