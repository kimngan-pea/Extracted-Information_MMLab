import 'package:extracted_information/Screen/Authentication/SignIn.dart';
import 'package:extracted_information/Screen/Authentication/register.dart';
import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {

  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }
  
  @override
  Widget build(BuildContext context) {
    if(showSignIn) {
      return LoginPage(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  }
}