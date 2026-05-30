import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:drift/models/drift_report.dart';
import 'package:drift/services/report_loader.dart';
import 'package:drift/widgets/background_pattern.dart';
import 'package:drift/widgets/custom_navbar.dart';
import 'package:drift/widgets/debt_category_card.dart';
import 'package:drift/widgets/score_header.dart';
import 'package:drift/widgets/top_action_banner.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLiveDemo = false;

  Future<void> _openUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
        actions: <Widget>[
          _ModeBadge(isLive: _isLiveDemo),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: _isLiveDemo,
            onChanged: (bool value) {
              setState(() {
                _isLiveDemo = value;
              });
            },
          ),
        ],
      ),
      body: PatternedBackground(
        child: FutureBuilder<DriftReport>(
          future: _isLiveDemo
              ? ReportLoader().fetchLiveReport()
              : ReportLoader().loadMockReport(),
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

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ScoreHeader(
                          score: report.score,
                          scoreDelta: report.scoreDelta,
                          generatedAt: report.generatedAt,
                        ),
                        const SizedBox(height: 24),
                        TopActionBanner(topAction: report.topAction),
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
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Powered by Coral · github + linear + slack + notion',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ) ??
                            TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModeBadge extends StatefulWidget {
  const _ModeBadge({required this.isLive});

  final bool isLive;

  @override
  State<_ModeBadge> createState() => _ModeBadgeState();
}

class _ModeBadgeState extends State<_ModeBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.isLive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _ModeBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLive = widget.isLive;
    final Color baseColor = isLive
        ? const Color(0xFF22C55E)
        : const Color(0xFF64748B);
    final Color bgColor = baseColor.withValues(alpha: 0.12);

    final String text = isLive ? 'LIVE MODE' : 'MOCK DATA';

    return FadeTransition(
      opacity: isLive
          ? Tween<double>(begin: 0.65, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation<double>(1.0),
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: baseColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: baseColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
        ),
      ),
    );
  }
}
