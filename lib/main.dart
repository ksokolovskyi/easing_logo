import 'package:easing_logo/logo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Logo(),
              SizedBox(width: 10),
              Text(
                'Easing Graphs',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: -0.09,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
