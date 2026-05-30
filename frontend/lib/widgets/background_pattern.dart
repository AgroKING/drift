import 'package:flutter/material.dart';

class PatternedBackground extends StatelessWidget {
  final Widget child;

  const PatternedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/backgroundPattern.jpg'),
          repeat: ImageRepeat.repeat,
          opacity: 1, 
        ),
      ),
      child: child,
    );
  }
}