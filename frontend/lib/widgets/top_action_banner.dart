import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/drift_report.dart';

class TopActionBanner extends StatelessWidget {
  final TopAction topAction;

  const TopActionBanner({
    super.key,
    required this.topAction,
  });

  static const Color _surface = Color(0xFF1A1D27);
  static const Color _border = Color.fromRGBO(255, 255, 255, 0.06);
  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  Color _accentForType(String type) {
    // Accent color that matches the action type/category.
    switch (type.toLowerCase()) {
      case 'review':
        return const Color(0xFFEF4444);
      case 'reply':
        return const Color(0xFFF97316);
      case 'commitment':
        return const Color(0xFFEAB308);
      case 'staleness':
        return const Color(0xFF3B82F6);
      case 'drift':
        return const Color(0xFFA855F7);
      default:
        return _textSecondary;
    }
  }

  String _ctaLabelForUrl(Uri uri) {
    final String host = uri.host.toLowerCase();
    // CTA label based on well-known hosts.
    if (host.contains('github.com')) return '[ Open in GitHub → ]';
    if (host.contains('linear.app')) return '[ Open in Linear → ]';
    if (host.contains('slack.com')) return '[ Open in Slack → ]';
    if (host.contains('notion.so')) return '[ Open in Notion → ]';

    return '[ Open link → ]';
  }

  Future<void> _openUrl(BuildContext context) async {
    final Uri? uri = Uri.tryParse(topAction.url);
    // Validate the URL before attempting to open it.
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL.')),
      );
      return;
    }

    final bool ok = await launchUrl(
      uri,
      webOnlyWindowName: '_blank',
    );

    if (!ok) {
      // If the platform failed to open the link, notify the user.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentForType(topAction.type);
    final Uri? uri = Uri.tryParse(topAction.url);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            // Soft accent glow fading outwards.
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.0),
          ],
        ),
        boxShadow: <BoxShadow>[
          // Ambient backlight glow in the debt category accent color.
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 72,
            spreadRadius: 14,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'TOP PRIORITY',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '🎯 ${topAction.text}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: _textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  // Opens the action URL in a new browser tab/window.
                  onPressed: () async => _openUrl(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: accent.withValues(alpha: 0.35),
                      ),
                    ),
                    backgroundColor: accent.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    // Use a host-specific CTA when available, otherwise fallback.
                    uri == null ? '[ Open → ]' : _ctaLabelForUrl(uri),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
