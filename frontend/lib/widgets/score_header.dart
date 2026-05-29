import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Score header widget for Drift dashboard.
///
/// Displays the main score, a delta indicator (↑/↓ with accent color),
/// and the generated timestamp in a human-readable format.
class ScoreHeader extends StatelessWidget {
  final int score;
  final int scoreDelta;
  final DateTime generatedAt;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.scoreDelta,
    required this.generatedAt,
  });

  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  static const Color _deltaUpBad = Color(0xFFEF4444); // debt increased
  static const Color _deltaDownGood = Color(0xFF16A34A); // debt decreased

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatGeneratedAt(DateTime dateTime) {
    final DateTime local = dateTime.toLocal();

    final String month = _months[local.month - 1];
    final int day = local.day;
    final int year = local.year;

    final int hour24 = local.hour;
    final int hour12 = (hour24 % 12 == 0) ? 12 : hour24 % 12;
    final String minute = local.minute.toString().padLeft(2, '0');
    final String amPm = hour24 < 12 ? 'AM' : 'PM';

    return '$month $day, $year · $hour12:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUp = scoreDelta > 0;
    final String arrow = isUp ? '↑' : '↓';
    final Color deltaColor = isUp ? _deltaUpBad : _deltaDownGood;
    final int deltaMagnitude = scoreDelta.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Row(
        //   children: [
        //     Image.asset(
        //       'assets/logo.png',
        //       width: 32,
        //       height: 32,
        //      ),
        //      SizedBox(width: 8),
        //     Text(
        //       'DRIFT',
        //       style: GoogleFonts.inter(
        //         fontSize: 18,
        //         fontWeight: FontWeight.w700,
        //         letterSpacing: 1.4,
        //         color: _textPrimary,
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x120F172A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$score',
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        arrow,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deltaColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$deltaMagnitude',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: deltaColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Attention Debt Score',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '(red if positive, green if negative delta)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Generated: ${_formatGeneratedAt(generatedAt)}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }
}
