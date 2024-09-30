import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB3D3CD),
      child: const Center(
        child: SpinKitSpinningLines(
          color: Colors.green,
          size: 50.0
        ),
      )
    );
  }
}