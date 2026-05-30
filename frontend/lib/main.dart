import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'package:drift/views/demo_view.dart';

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
      theme: AppTheme.light,
      home: const DemoView(),
    );
  }
}
