import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:drift/models/drift_report.dart';
import 'package:drift/theme/app_theme.dart';

class TopActionBanner extends StatelessWidget {
  final TopAction topAction;

  const TopActionBanner({
    super.key,
    required this.topAction,
  });

  Color _accentForType(String type) {
    switch (type.toLowerCase()) {
      case 'review':
        return AppTheme.review;
      case 'reply':
        return AppTheme.reply;
      case 'commitment':
        return AppTheme.commitment;
      case 'staleness':
        return AppTheme.staleness;
      case 'drift':
        return AppTheme.drift;
      default:
        return AppTheme.textMuted;
    }
  }

  String _ctaLabelForUrl(Uri uri) {
    final String host = uri.host.toLowerCase();
    if (host.contains('github.com')) return 'Open in GitHub →';
    if (host.contains('linear.app')) return 'Open in Linear →';
    if (host.contains('slack.com')) return 'Open in Slack →';
    if (host.contains('notion.so')) return 'Open in Notion →';
    return 'Open link →';
  }

  Future<void> _openUrl(BuildContext context) async {
    final String? url = topAction.url;
    if (url == null || url.isEmpty) return;
    
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL.')),
        );
      }
      return;
    }

    final bool ok = await launchUrl(uri, webOnlyWindowName: '_blank');

    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentForType(topAction.type);
    final String? url = topAction.url;
    final Uri? uri = (url != null && url.isNotEmpty) ? Uri.tryParse(url) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.35),
            accent.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 72,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'TOP PRIORITY',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                height: 1.2,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '🎯 ${topAction.text}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (uri != null) ...[
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: () async => _openUrl(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(
                          color: accent.withValues(alpha: 0.35),
                        ),
                      ),
                      backgroundColor: AppTheme.surfaceOverlay,
                    ),
                    child: Text(
                      _ctaLabelForUrl(uri),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
