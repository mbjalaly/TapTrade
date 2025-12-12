// import 'package:flutter/material.dart';
// import 'package:simple_animations/simple_animations.dart';
//
// enum AnimationType { opacity, translateX, translateY }
//
// enum AnimationDirection { ltr, rtl, ttb, btt, ttc, btc }
//
// class FadeAnimation extends StatelessWidget {
//   final double delay;
//   final Widget child;
//   final AnimationDirection direction;
//
//   FadeAnimation({
//     required this.delay,
//     required this.child,
//     this.direction = AnimationDirection.ltr,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final tween = MultiTween<AnimationType>();
//
//     // Set initial and final values based on direction
//     double beginX = 0.0;
//     double endX = 0.0;
//     double beginY = 0.0;
//     double endY = 0.0;
//
//     switch (direction) {
//       case AnimationDirection.ltr:
//         beginX = -30.0;
//         endX = 0.0;
//         break;
//       case AnimationDirection.rtl:
//         beginX = 30.0;
//         endX = 0.0;
//         break;
//       case AnimationDirection.ttb:
//         beginY = -30.0;
//         endY = 0.0;
//         break;
//       case AnimationDirection.btt:
//         beginY = 30.0;
//         endY = 0.0;
//         break;
//       case AnimationDirection.ttc:
//         beginY = -30.0;
//         endY = MediaQuery.of(context).size.height / 2;
//         break;
//       case AnimationDirection.btc:
//         beginY = 30.0;
//         endY = MediaQuery.of(context).size.height / 2;
//         break;
//     }
//
//     tween
//       ..add(
//         AnimationType.opacity,
//         Tween(begin: 0.0, end: 1.0),
//         Duration(milliseconds: 500),
//       )
//       ..add(
//         AnimationType.translateX,
//         Tween(begin: beginX, end: endX),
//         Duration(milliseconds: 500),
//       )
//       ..add(
//         AnimationType.translateY,
//         Tween(begin: beginY, end: endY),
//         Duration(milliseconds: 500),
//       );
//
//     return PlayAnimation<MultiTweenValues<AnimationType>>(
//       delay: Duration(milliseconds: (500 * delay).round()),
//       duration: tween.duration,
//       tween: tween,
//       child: child,
//       builder: (context, child, value) => Opacity(
//         opacity: value.get(AnimationType.opacity),
//         child: Transform.translate(
//           offset: Offset(
//             value.get(AnimationType.translateX),
//             value.get(AnimationType.translateY),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// // FadeAnimation(
// // delay: 1.0,
// // child: YourWidget(),
// // direction: AnimationDirection.ltr,
// // )

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum AnimationType { opacity, translateX, translateY }

enum AnimationDirection { ltr, rtl, ttb, btt, ttc, btc }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final AnimationDirection direction;

  const FadeAnimation({
    super.key,
    required this.delay,
    required this.child,
    this.direction = AnimationDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    double beginX = 0.0;
    double endX = 0.0;
    double beginY = 0.0;
    double endY = 0.0;

    switch (direction) {
      case AnimationDirection.ltr:
        beginX = -30.0;
        endX = 0.0;
        break;
      case AnimationDirection.rtl:
        beginX = 30.0;
        endX = 0.0;
        break;
      case AnimationDirection.ttb:
        beginY = -30.0;
        endY = 0.0;
        break;
      case AnimationDirection.btt:
        beginY = 30.0;
        endY = 0.0;
        break;
      case AnimationDirection.ttc:
        beginY = -30.0;
        endY = MediaQuery.of(context).size.height / 2;
        break;
      case AnimationDirection.btc:
        beginY = 30.0;
        endY = MediaQuery.of(context).size.height / 2;
        break;
    }

    final tween = MovieTween()
      ..tween('opacity', Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500))
      ..tween('translateX', Tween(begin: beginX, end: endX),
          duration: const Duration(milliseconds: 500))
      ..tween('translateY', Tween(begin: beginY, end: endY),
          duration: const Duration(milliseconds: 500));

    return PlayAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      delay: Duration(milliseconds: (500 * delay).round()),
      builder: (context, value, _) {
        return Opacity(
          opacity: value.get('opacity'),
          child: Transform.translate(
            offset: Offset(
              value.get('translateX'),
              value.get('translateY'),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
