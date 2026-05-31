import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drift/theme/app_theme.dart';

class MovingBlobsBackground extends StatefulWidget {
  const MovingBlobsBackground({super.key});

  @override
  State<MovingBlobsBackground> createState() => _MovingBlobsBackgroundState();
}

class _MovingBlobsBackgroundState extends State<MovingBlobsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final double blobAlpha = isDark ? 0.15 : 0.22;
    final double wave1Alpha = isDark ? 0.12 : 0.22;
    final double wave2Alpha = isDark ? 0.08 : 0.18;
    final double noiseOpacity = isDark ? 0.035 : 0.055;

    return Stack(
      children: [
        // Deep static background color
        Container(color: AppTheme.background),
        // Drifting colored mesh gradient blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double value = _controller.value * 2 * math.pi;

            // Blob 1: Review Debt Red (Top-Left)
            final double x1 = width * 0.15 + math.sin(value) * 80;
            final double y1 = height * 0.15 + math.cos(value) * 60;

            // Blob 2: Reply Debt Orange (Right)
            final double x2 = width * 0.75 + math.sin(value + math.pi / 2) * 100;
            final double y2 = height * 0.35 + math.cos(value + math.pi / 2) * 70;

            // Blob 3: Commitment Debt Yellow (Bottom-Left)
            final double x3 = width * 0.20 + math.sin(value + math.pi) * 90;
            final double y3 = height * 0.75 + math.cos(value + math.pi) * 110;

            // Blob 4: Staleness Debt Blue (Center-Left)
            final double x4 = width * 0.40 + math.cos(value * 0.8) * 110;
            final double y4 = height * 0.50 + math.sin(value * 0.8) * 80;

            // Blob 5: Drift Debt Purple (Bottom-Right)
            final double x5 = width * 0.80 + math.sin(value * 1.1) * 70;
            final double y5 = height * 0.85 + math.cos(value * 1.1) * 90;

            return Stack(
              children: [
                _buildBlob(x1, y1, width * 0.45, AppTheme.review.withValues(alpha: blobAlpha)),
                _buildBlob(x2, y2, width * 0.40, AppTheme.reply.withValues(alpha: blobAlpha)),
                _buildBlob(x3, y3, width * 0.50, AppTheme.commitment.withValues(alpha: blobAlpha)),
                _buildBlob(x4, y4, width * 0.35, AppTheme.staleness.withValues(alpha: blobAlpha)),
                _buildBlob(x5, y5, width * 0.45, AppTheme.drift.withValues(alpha: blobAlpha)),
              ],
            );
          },
        ),
        // Frost effect that blends everything together into a smooth mesh gradient
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120.0, sigmaY: 120.0),
            child: const SizedBox.shrink(),
          ),
        ),
        // Sharp animated wave lines drawn on top of the blur overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animValue: _controller.value,
                  color1: AppTheme.accent.withValues(alpha: wave1Alpha),
                  color2: AppTheme.staleness.withValues(alpha: wave2Alpha),
                ),
              );
            },
          ),
        ),
        // Passive noise texture overlay painted on top of the entire background stack
        Positioned.fill(
          child: CustomPaint(
            painter: NoisePainter(opacity: noiseOpacity),
          ),
        ),
      ],
    );
  }

  Widget _buildBlob(double x, double y, double size, Color color) {
    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class HoverLift extends StatefulWidget {
  final Widget child;
  const HoverLift({super.key, required this.child});

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        child: widget.child,
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animValue;
  final Color color1;
  final Color color2;

  const WavePainter({
    required this.animValue,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height * 0.70);
    path2.moveTo(0, size.height * 0.78);

    for (double x = 0; x <= size.width; x += 2.0) {
      // Wave 1: Sine wave with horizontal animation offset
      final double y1 = size.height * 0.70 +
          math.sin((x / size.width * 2 * math.pi) + animValue * 2 * math.pi) * 25 +
          math.cos((x / size.width * 4 * math.pi) - animValue * 2 * math.pi) * 10;
      path1.lineTo(x, y1);

      // Wave 2: Slower frequency cosine wave
      final double y2 = size.height * 0.78 +
          math.cos((x / size.width * 1.5 * math.pi) - animValue * 2 * math.pi) * 20 +
          math.sin((x / size.width * 3 * math.pi) + animValue * 2 * math.pi) * 8;
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

class NoisePainter extends CustomPainter {
  final double opacity;
  const NoisePainter({this.opacity = 0.035});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1.0;
    
    // Seeded random number generator so the noise grain remains consistent and static
    final random = math.Random(101);

    // Render a sparse grid of micro-points with a slight random offset
    const double step = 6.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (random.nextDouble() > 0.65) {
          final double offsetX = random.nextDouble() * step;
          final double offsetY = random.nextDouble() * step;
          canvas.drawPoints(
            PointMode.points,
            [Offset(x + offsetX, y + offsetY)],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) => false;
}
