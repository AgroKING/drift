import 'package:flutter/material.dart';

import 'models/drift_report.dart';
import 'services/report_loader.dart';
import 'theme/app_theme.dart';
import 'widgets/debt_category_card.dart';
import 'widgets/score_header.dart';
import 'widgets/top_action_banner.dart';

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

          final List<Widget> reviewItems = report.debts.review
              .map((ReviewDebt d) => ReviewDebtRow(debt: d))
              .toList();

          final List<Widget> replyItems = report.debts.reply
              .map((ReplyDebt d) => ReplyDebtRow(debt: d))
              .toList();

          final List<Widget> commitmentItems = report.debts.commitment
              .map((CommitmentDebt d) => CommitmentDebtRow(debt: d))
              .toList();

          final List<Widget> stalenessItems = report.debts.staleness
              .map((StalenessDebt d) => StalenessDebtRow(debt: d))
              .toList();

          final List<Widget> driftItems = report.debts.drift
              .map((DriftDebt d) => DriftDebtRow(debt: d))
              .toList();

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
                      const SizedBox(height: 24),
                      TopActionBanner(topAction: snapshot.data!.topAction),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DebtCategoryCard(
                    emoji: '🔴',
                    label: 'Review Debt',
                    accentColor: const Color(0xFFEF4444),
                    itemCount: report.debts.review.length,
                    children: reviewItems,
                  ),
                  const SizedBox(height: 16),
                  DebtCategoryCard(
                    emoji: '🟠',
                    label: 'Reply Debt',
                    accentColor: const Color(0xFFF97316),
                    itemCount: report.debts.reply.length,
                    children: replyItems,
                  ),
                  const SizedBox(height: 16),
                  DebtCategoryCard(
                    emoji: '🟡',
                    label: 'Commitment Debt',
                    accentColor: const Color(0xFFEAB308),
                    itemCount: report.debts.commitment.length,
                    children: commitmentItems,
                  ),
                  const SizedBox(height: 16),
                  DebtCategoryCard(
                    emoji: '🔵',
                    label: 'Staleness Debt',
                    accentColor: const Color(0xFF3B82F6),
                    itemCount: report.debts.staleness.length,
                    children: stalenessItems,
                  ),
                  const SizedBox(height: 16),
                  DebtCategoryCard(
                    emoji: '🟣',
                    label: 'Drift Debt',
                    accentColor: const Color(0xFFA855F7),
                    itemCount: report.debts.drift.length,
                    children: driftItems,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
