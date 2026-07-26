import 'package:flutter/material.dart';
import 'package:thingsboard_app/config/themes/tb_text_styles.dart';

class EndpointNameWidget extends StatelessWidget {
  const EndpointNameWidget({required this.endpoint, super.key});

  final String endpoint;

  /// Brand-friendly label: our production backend shows as "AgriPulse Cloud"
  /// instead of the raw vendor hostname; any other endpoint (e.g. a future
  /// self-hosted server) still shows its real host for clarity.
  static String _displayName(String endpoint) {
    final host = Uri.parse(endpoint).host;
    if (host == 'thingsboard.cloud' || host.endsWith('.thingsboard.cloud')) {
      return 'AgriPulse Cloud';
    }
    return host;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).primaryColor.withValues(alpha: .06),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Center(
        child: Text(
          _displayName(endpoint),
          style: TbTextStyles.bodySmall.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
