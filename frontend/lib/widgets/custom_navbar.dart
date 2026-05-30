import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:drift/theme/app_theme.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLive;
  final ValueChanged<bool> onToggle;

  const CustomNavBar({
    super.key,
    required this.isLive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppTheme.surface.withValues(alpha: 0.35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Drift',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          _ModeBadge(isLive: isLive),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                            value: isLive,
                            onChanged: onToggle,
                            activeThumbColor: AppTheme.success,
                            activeTrackColor: AppTheme.success.withValues(alpha: 0.2),
                            inactiveThumbColor: AppTheme.textMuted,
                            inactiveTrackColor: AppTheme.border,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(104);
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
    final Color baseColor = isLive ? AppTheme.success : AppTheme.textMuted;
    final Color bgColor = baseColor.withValues(alpha: 0.12);

    final String text = isLive ? 'LIVE MODE' : 'MOCK DATA';

    return FadeTransition(
      opacity: isLive
          ? Tween<double>(begin: 0.65, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation<double>(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: baseColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: baseColor,
          ),
        ),
      ),
    );
  }
}
