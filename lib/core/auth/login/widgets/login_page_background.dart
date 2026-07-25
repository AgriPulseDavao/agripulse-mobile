import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/auth/login/widgets/header/ce_login_header.dart';

/// Dark navy gradient backdrop matching agripulse.ph's hero section,
/// with the site's subtle diagonal accent shapes.
class LoginPageBackground extends StatelessWidget {
  const LoginPageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: const _LoginPageBackgroundPainter()),
    );
  }
}

class _LoginPageBackgroundPainter extends CustomPainter {
  const _LoginPageBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AgriPulseBrand.navy, AgriPulseBrand.navyLight],
      ).createShader(rect);
    canvas.drawRect(rect, gradient);

    final deco = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.fill;
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, 0)
      ..lineTo(0, size.height / 10)
      ..close();
    canvas.drawPath(topPath, deco);
    final bottomPath = Path()
      ..moveTo(0, size.height * 0.98)
      ..lineTo(size.width, size.height * 0.78)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottomPath, deco);
  }

  @override
  bool shouldRepaint(covariant _LoginPageBackgroundPainter oldDelegate) =>
      false;
}
