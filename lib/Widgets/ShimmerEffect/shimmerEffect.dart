import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

class CustomShimmer extends StatefulWidget {
  final Widget child;
  final bool isOn;

  const CustomShimmer({super.key, required this.child, required this.isOn});

  @override
  CustomShimmerState createState() => CustomShimmerState();
}

class CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _toggleAnimation();
  }

  @override
  void didUpdateWidget(CustomShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn) {
      _toggleAnimation();
    }
  }

  void _toggleAnimation() {
    if (widget.isOn) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!widget.isOn) {
      return widget.child;
    }else{
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  AppColors.blackTextColor.withOpacity(0.3),
                  AppColors.blackTextColor.withOpacity(0.1),
                  AppColors.blackTextColor.withOpacity(0.3),
                ],
                stops: const [0.1, 0.5, 0.9],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: SlidingGradientTransform(
                  slidePercent: _controller.value,
                ),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
        child: widget.child,
      );
    }
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
