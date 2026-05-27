import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const DriftApp());
}

class DriftApp extends StatelessWidget {
  const DriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drift',
      theme: AppTheme.dark,
      home: const DriftHomeScreen(),
    );
  }
}

class DriftHomeScreen extends StatelessWidget {
  const DriftHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Text(
                'DRIFT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Foundational layout + theme applied.',
              ),
              SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );
  }
}
