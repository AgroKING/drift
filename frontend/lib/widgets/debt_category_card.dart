import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/drift_report.dart';

class DebtCategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color accentColor;
  final int itemCount;
  final List<Widget> children;

  const DebtCategoryCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.accentColor,
    required this.itemCount,
    required this.children,
  });

  static const Color _surface = Color(0xFF1A1D27);
  static const Color _border = Color.fromRGBO(255, 255, 255, 0.06);
  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    // Label for the number of items in this category.
    final String countLabel = itemCount == 1 ? '1 item' : '$itemCount items';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: <Widget>[
            // Frosted-glass look with blur and a semi-transparent background color.
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: _surface.withValues(alpha: 0.92),
              ),
            ),
            // Accent indicator strip.
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                // Thin vertical strip used as a visual accent for the category.
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.85),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        emoji,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        countLabel,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Show an empty placeholder when there are no items,
                  // otherwise render the list of item widgets.
                  if (itemCount == 0)
                    _EmptyState(accentColor: accentColor)
                  else
                    _ItemsContainer(
                      accentColor: accentColor,
                      children: children,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color accentColor;

  const _EmptyState({required this.accentColor});

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '✅',
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "You're caught up — no items waiting for you",
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsContainer extends StatelessWidget {
  final Color accentColor;
  final List<Widget> children;

  const _ItemsContainer({
    required this.accentColor,
    required this.children,
  });

  static const Color _border = Color.fromRGBO(255, 255, 255, 0.06);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            // Insert a divider between items (but not before the first one).
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: children[i],
            ),
          ],
        ],
      ),
    );
  }
}

class ReviewDebtRow extends StatelessWidget {
  final ReviewDebt debt;

  const ReviewDebtRow({
    super.key,
    required this.debt,
  });

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    // Optional block count displayed after the main metadata (if present).
    final String blocks = debt.blocks == null ? '' : ' · ⛓ ${debt.blocks}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PR #${debt.prNumber} · "${debt.title}" · @${debt.author}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${debt.repo} · ⏱ ${debt.daysWaiting} days · 💬 ${debt.slackMentions} Slack asks$blocks',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}

class ReplyDebtRow extends StatelessWidget {
  final ReplyDebt debt;

  const ReplyDebtRow({
    super.key,
    required this.debt,
  });

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  String _sourceLabel(String source) {
    switch (source.toLowerCase()) {
      case 'slack':
        return 'Slack';
      case 'notion':
        return 'Notion';
      case 'linear':
        return 'Linear';
      case 'github':
        return 'GitHub';
      default:
        return source;
    }
  }

  String _sourceIcon(String source) {
    switch (source.toLowerCase()) {
      case 'slack':
        return '💬';
      case 'notion':
        return '📝';
      case 'linear':
        return '📌';
      case 'github':
        return '🐙';
      default:
        return '🔔';
    }
  }

  String _agoLabel(int daysAgo) {
    if (daysAgo == 1) return '1 day ago';
    return '$daysAgo days ago';
  }

  @override
  Widget build(BuildContext context) {
    final String label = _sourceLabel(debt.source);
    final String icon = _sourceIcon(debt.source);

    final String channelLabel = debt.source.toLowerCase() == 'slack'
        ? '#${debt.channel.replaceAll('#', '')}'
        : debt.channel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$icon $label $channelLabel · @${debt.from} · ${_agoLabel(debt.daysAgo)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '"${debt.preview}"',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}

class CommitmentDebtRow extends StatelessWidget {
  final CommitmentDebt debt;

  const CommitmentDebtRow({
    super.key,
    required this.debt,
  });

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final bool showWarning = debt.daysStale >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${debt.taskId} · "${debt.title}"',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Status: ${debt.status} · Last commit: ${debt.daysStale}d ago',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        if (showWarning) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            '⚠️ No Git activity matching this task',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class StalenessDebtRow extends StatelessWidget {
  final StalenessDebt debt;

  const StalenessDebtRow({
    super.key,
    required this.debt,
  });

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final bool nobodyLooking = debt.reviews == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PR #${debt.prNumber} · "${debt.title}" · ${debt.repo}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Open ${debt.daysStale} days · ${debt.reviews} reviews',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        if (nobodyLooking) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            "💡 Nobody's looking at it. Ping #frontend?",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class DriftDebtRow extends StatelessWidget {
  final DriftDebt debt;

  const DriftDebtRow({
    super.key,
    required this.debt,
  });

  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${debt.taskId} "${debt.taskTitle}" → marked ${debt.taskStatus}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'but PR #${debt.prNumber} is still ${debt.prStatus} in GitHub',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '⚠️ Either merge the PR or reopen the task',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}
