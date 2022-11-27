import 'dart:ui';

import 'package:flutter/material.dart';

class ZoomOutAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Color tintColor;
  final CurvedAnimation _curvedAnimation;

  late final Animation<int> _maskOpacityAnimation;
  late final Animation<double> _zoomAnimation;
  late final Animation<double> _blurAnimation;

  final Widget? child;

  ZoomOutAnimation(
      {Key? key,
      required this.animation,
      this.tintColor = Colors.black,
      this.child})
      : _curvedAnimation = CurvedAnimation(
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
          parent: animation,
        ),
        super(key: key) {
    _maskOpacityAnimation =
        IntTween(begin: 0, end: 127).animate(_curvedAnimation);
    _zoomAnimation =
        Tween<double>(begin: 1.0, end: 1.5).animate(_curvedAnimation);
    _blurAnimation =
        Tween<double>(begin: 0.0, end: 10.0).animate(_curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scale: _zoomAnimation.value,
                child: child,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Container(
                  color: tintColor.withAlpha(_maskOpacityAnimation.value),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}
