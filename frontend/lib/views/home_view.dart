import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:drift/models/drift_report.dart';
import 'package:drift/services/report_loader.dart';
import 'package:drift/theme/app_theme.dart';
import 'package:drift/widgets/ai_insight_card.dart';
import 'package:drift/widgets/custom_navbar.dart';
import 'package:drift/widgets/debt_category_card.dart';
import 'package:drift/widgets/score_header.dart';
import 'package:drift/widgets/top_action_banner.dart';
import 'package:drift/widgets/moving_blobs_background.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLiveDemo = false;

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: CustomNavBar(
        isLive: _isLiveDemo,
        onToggle: (bool value) {
          setState(() {
            _isLiveDemo = value;
          });
        },
      ),
      body: Stack(
        children: <Widget>[
          const MovingBlobsBackground(),
          FutureBuilder<DriftReport>(
        future: _isLiveDemo
            ? ReportLoader().fetchLiveReport()
            : ReportLoader().loadMockReport(),
        builder: (BuildContext context, AsyncSnapshot<DriftReport> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load report: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.error),
              ),
            );
          }

          final DriftReport? report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('No report data.'));
          }

          final List<Widget> reviewItems = report.debts.review
              .map((ReviewDebt d) => ReviewDebtRow(debt: d, onOpen: () => _openUrl(d.url)))
              .toList();

          final List<Widget> replyItems = report.debts.reply
              .map((ReplyDebt d) => ReplyDebtRow(debt: d))
              .toList();

          final List<Widget> commitmentItems = report.debts.commitment
              .map((CommitmentDebt d) => CommitmentDebtRow(debt: d))
              .toList();

          final List<Widget> stalenessItems = report.debts.staleness
              .map((StalenessDebt d) => StalenessDebtRow(
                    debt: d,
                    onOpen: () => _openUrl(d.url),
                  ))
              .toList();

          final List<Widget> driftItems = report.debts.drift
              .map((DriftDebt d) => DriftDebtRow(debt: d))
              .toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 128, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ScoreHeader(
                      score: report.score,
                      scoreDelta: report.scoreDelta,
                      generatedAt: report.generatedAt,
                    ),
                    const SizedBox(height: 40),
                    HoverLift(child: TopActionBanner(topAction: report.topAction)),
                    const SizedBox(height: 40),
                    if (report.insight != null && report.insight!.isNotEmpty) ...<Widget>[
                      HoverLift(
                        child: AiInsightCard(
                          insight: report.insight!,
                          suggestedPlan: report.suggestedPlan,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    HoverLift(
                      child: DebtCategoryCard(
                        emoji: '🔴',
                        label: 'Review Debt',
                        accentColor: AppTheme.review,
                        itemCount: report.debts.review.length,
                        children: reviewItems,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HoverLift(
                      child: DebtCategoryCard(
                        emoji: '🟠',
                        label: 'Reply Debt',
                        accentColor: AppTheme.reply,
                        itemCount: report.debts.reply.length,
                        children: replyItems,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HoverLift(
                      child: DebtCategoryCard(
                        emoji: '🟡',
                        label: 'Commitment Debt',
                        accentColor: AppTheme.commitment,
                        itemCount: report.debts.commitment.length,
                        children: commitmentItems,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HoverLift(
                      child: DebtCategoryCard(
                        emoji: '🔵',
                        label: 'Staleness Debt',
                        accentColor: AppTheme.staleness,
                        itemCount: report.debts.staleness.length,
                        children: stalenessItems,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HoverLift(
                      child: DebtCategoryCard(
                        emoji: '🟣',
                        label: 'Drift Debt',
                        accentColor: AppTheme.drift,
                        itemCount: report.debts.drift.length,
                        children: driftItems,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'Powered by Coral · github + linear + slack + notion',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ],
  ),
);
}
}
