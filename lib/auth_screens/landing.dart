import 'package:cashflow/auth_screens/auth_screen.dart';
import 'package:cashflow/back/auth_service/model.dart';
import 'package:cashflow/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = Provider.of<UserModel?>(context);
    print(userModel);
    final bool check = userModel != null;
    print(check);
    return check ? const NavigationScreen() : const AuthScreen();
  }
}
