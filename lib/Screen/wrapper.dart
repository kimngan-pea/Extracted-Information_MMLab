import 'package:extracted_information/Models/user.dart';
import 'package:extracted_information/Screen/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:extracted_information/Screen/Authentication/authentication.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<Users?>(context);
    
    //return either Home or Authentication widget
    if(user == null) {
      return const Authentication();
    } else {
      return Home();
    }
  }
}