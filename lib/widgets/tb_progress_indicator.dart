import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';

class TbProgressIndicator extends ProgressIndicator {

  const TbProgressIndicator({
    super.key,
    this.size = 36.0,
    super.valueColor,
    super.semanticsLabel,
    super.semanticsValue,
  }) : super(
          value: null,
        );
  final double size;

  @override
  State<StatefulWidget> createState() => _TbProgressIndicatorState();

  /// AgriPulse brand green — the spinner arc color (matches agripulse.ph).
  static const Color _brandGreen = Color(0xFF2FBF71);

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? _brandGreen;
}

class _TbProgressIndicatorState extends State<TbProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );
    _rotation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat();
  }

  @override
  void didUpdateWidget(TbProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Full-color AgriPulse leaf mark (no tint) in the center.
          SvgPicture.asset(
            ThingsboardImage.agriPulseMark,
            height: widget.size * 0.68,
            width: widget.size * 0.68,
          ),
          // Brand-green arc spinning around it.
          AnimatedBuilder(
            animation: _rotation,
            child: SvgPicture.asset(
              ThingsboardImage.thingsboardOuter,
              height: widget.size,
              width: widget.size,
              colorFilter: ColorFilter.mode(
                widget._getValueColor(context),
                BlendMode.srcIn,
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: _rotation.value * pi * 2,
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }
}
