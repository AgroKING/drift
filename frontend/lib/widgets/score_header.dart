import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:drift/theme/app_theme.dart';

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

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    final Color deltaColor = isUp ? AppTheme.scoreUp : AppTheme.scoreDown;
    final int deltaMagnitude = scoreDelta.abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40000000), // 0.25 alpha black
                    blurRadius: 24,
                    offset: Offset(0, 4),
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
                      color: AppTheme.textPrimary,
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
                      const SizedBox(width: 4),
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
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Attention Debt Score',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generated: ${_formatGeneratedAt(generatedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
