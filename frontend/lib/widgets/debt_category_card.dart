import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:drift/models/drift_report.dart';
import 'package:drift/theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final String countLabel = itemCount == 1 ? '1 item' : '$itemCount items';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        color: AppTheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 72,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Text(
                          countLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.surfaceElevated,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('✅', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "You're caught up — no items waiting for you",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.45,
                color: AppTheme.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        color: AppTheme.surfaceElevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class ReviewDebtRow extends StatefulWidget {
  final ReviewDebt debt;
  final VoidCallback? onOpen;

  const ReviewDebtRow({
    super.key,
    required this.debt,
    this.onOpen,
  });

  @override
  State<ReviewDebtRow> createState() => _ReviewDebtRowState();
}

class _ReviewDebtRowState extends State<ReviewDebtRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String blocks = widget.debt.blocks == null ? '' : ' · ⛓ ${widget.debt.blocks}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onOpen,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppTheme.surfaceOverlay,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: _isHovered ? 22.0 : 16.0,
            right: _isHovered ? 10.0 : 16.0,
            top: 16,
            bottom: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: _isHovered ? AppTheme.accent : AppTheme.textPrimary,
                      ),
                      child: Text(
                        'PR #${widget.debt.prNumber} · "${widget.debt.title}" · @${widget.debt.author}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.debt.repo} · ⏱ ${widget.debt.daysWaiting} days · 💬 ${widget.debt.slackMentions} Slack asks$blocks',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.debt.url != null && widget.debt.url!.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, _isHovered ? -4.0 : 0.0, 0.0),
                  child: Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: _isHovered ? AppTheme.accent : AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReplyDebtRow extends StatelessWidget {
  final ReplyDebt debt;

  const ReplyDebtRow({
    super.key,
    required this.debt,
  });

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$icon $label $channelLabel · @${debt.from} · ${_agoLabel(debt.daysAgo)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"${debt.preview}"',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class CommitmentDebtRow extends StatelessWidget {
  final CommitmentDebt debt;

  const CommitmentDebtRow({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    final bool showWarning = debt.daysStale >= 10;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${debt.taskId} · "${debt.title}"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Status: ${debt.status} · Last commit: ${debt.daysStale}d ago',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppTheme.textSecondary,
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
                fontWeight: FontWeight.w600,
                color: AppTheme.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StalenessDebtRow extends StatefulWidget {
  final StalenessDebt debt;
  final VoidCallback? onOpen;

  const StalenessDebtRow({
    super.key,
    required this.debt,
    this.onOpen,
  });

  @override
  State<StalenessDebtRow> createState() => _StalenessDebtRowState();
}

class _StalenessDebtRowState extends State<StalenessDebtRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool nobodyLooking = widget.debt.reviews == 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onOpen,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppTheme.surfaceOverlay,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: _isHovered ? 22.0 : 16.0,
            right: _isHovered ? 10.0 : 16.0,
            top: 16,
            bottom: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: _isHovered ? AppTheme.accent : AppTheme.textPrimary,
                      ),
                      child: Text(
                        'PR #${widget.debt.prNumber} · "${widget.debt.title}" · ${widget.debt.repo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open ${widget.debt.daysStale} days · ${widget.debt.reviews} reviews',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: AppTheme.textSecondary,
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
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.debt.url != null && widget.debt.url!.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, _isHovered ? -4.0 : 0.0, 0.0),
                  child: Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: _isHovered ? AppTheme.accent : AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DriftDebtRow extends StatelessWidget {
  final DriftDebt debt;

  const DriftDebtRow({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${debt.taskId} "${debt.taskTitle}" → marked ${debt.taskStatus}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'but PR #${debt.prNumber} is still ${debt.prStatus} in GitHub',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '⚠️',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.drift,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  debt.contradiction,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppTheme.drift,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
