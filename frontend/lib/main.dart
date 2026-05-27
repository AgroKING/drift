import 'package:flutter/material.dart';

import 'models/drift_report.dart';
import 'services/report_loader.dart';
import 'theme/app_theme.dart';
import 'widgets/score_header.dart';

void main() {
  // Start the Flutter app by inflating the root widget.
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

class DriftHomeScreen extends StatefulWidget {
  const DriftHomeScreen({super.key});

  @override
  State<DriftHomeScreen> createState() => _DriftHomeScreenState();
}

class _DriftHomeScreenState extends State<DriftHomeScreen> {
  // Service used to obtain report data for the home screen.
  final ReportLoader _reportLoader = ReportLoader();
  // Kick off loading the demo report once when the state is created.
  late final Future<DriftReport> _reportFuture = _reportLoader.loadMockReport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Builds UI that reacts to the asynchronous report loading.
      body: FutureBuilder<DriftReport>(
        // The future the builder listens to for report data.
        future: _reportFuture,
        builder: (BuildContext context, AsyncSnapshot<DriftReport> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load report: ${snapshot.error}'),
            );
          }

          final DriftReport? report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('No report data.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header widget that displays the main score and metadata.
                      ScoreHeader(
                        score: report.score,
                        scoreDelta: report.scoreDelta,
                        generatedAt: report.generatedAt,
                      ),
                    ],
                  ),
                  const SizedBox(height: 800),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
