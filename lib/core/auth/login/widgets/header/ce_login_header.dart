import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';

/// AgriPulse brand colors (matched to agripulse.ph)
abstract class AgriPulseBrand {
  static const navy = Color(0xFF062330);
  static const navyLight = Color(0xFF11455E);
  static const leafNavy = Color(0xFF0B3549);
  static const green = Color(0xFF2FBF71);
  static const lime = Color(0xFF8EE6B0);
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(ThingsboardImage.agriPulseMark, height: 44),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'AgriPulse',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                Text(
                  'DAVAO',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.2,
                    color: AgriPulseBrand.lime,
                    height: 1.2,
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
