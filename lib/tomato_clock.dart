import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

class TomatoClock extends StatefulWidget {
  final Color workingColor;
  final Color restingColor;
  final TomatoClockController controller;

  const TomatoClock(
      {Key? key,
      required this.workingColor,
      required this.restingColor,
      required this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TomatoClockState();
  }
}

class _TomatoClockState extends State<TomatoClock>
    with TickerProviderStateMixin {
  late final TomatoClockController _controller = widget.controller;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  final _roundTween = Tween(begin: 0.0, end: pi * 2);

  String generateTimeString(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30));

    _animation = _roundTween.animate(_animationController);

    _controller.addListener(() {
      if (_controller.value.isRunning && !_animationController.isAnimating) {
        _animationController.repeat();
      } else if (!_controller.value.isRunning &&
          _animationController.isAnimating) {
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        child: CustomPaint(
          willChange: true,
          painter: _TomatoClockPainter(
              workingColor: widget.workingColor,
              restingColor: widget.restingColor,
              listenable: _animation),
          child: AspectRatio(
            aspectRatio: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, TomatoClockValue value, child) {
                      Color foreground =
                          value.status == TomatoClockStatus.working
                              ? widget.workingColor
                              : widget.restingColor;

                      String clockContent =
                          value.status == TomatoClockStatus.working
                              ? generateTimeString(value.currentCycleSeconds)
                              : 'REST';
                      return Text(
                        clockContent,
                        style: TextStyle(
                            color: foreground,
                            fontFamily: "E1234",
                            fontFeatures: const [FontFeature.tabularFigures()]),
                      );
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 画那种时钟的效果
class _TomatoClockPainter extends CustomPainter {
  final Animation<dynamic> listenable;

  final Color workingColor;
  final Color restingColor;

  const _TomatoClockPainter(
      {required this.workingColor,
      required this.restingColor,
      required this.listenable})
      : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = workingColor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final r = size.width / 2;
    final drawingRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: r * 2,
        height: r * 2);
    final arc = listenable.value;

    const start = -pi / 2;

    const split = 2 * pi * 25 / 30;

    canvas.drawArc(drawingRect, start, split, false, paint);

    paint.color = restingColor;
    canvas.drawArc(drawingRect, start + split, 2 * pi - split, false, paint);

    final dotOffset = Offset(size.width / 2 + r * cos(start + arc),
        size.height / 2 + r * sin(start + arc));

    paint.style = PaintingStyle.fill;
    if (arc > split) {
      paint.color = restingColor;
    } else {
      paint.color = workingColor;
    }

    canvas.drawCircle(dotOffset, 8, paint);
  }

  @override
  bool shouldRepaint(covariant _TomatoClockPainter oldDelegate) {
    return !(listenable.isCompleted || listenable.isDismissed);
  }
}

class TomatoClockController extends ValueNotifier<TomatoClockValue> {
  TomatoClockController() : super(TomatoClockValue());
  Timer? _timer;

  void start() {
    value.isRunning = true;

    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ++value.totalSeconds;

      if (value.totalSeconds % 30 < 25) {
        ++value.totalLearningSeconds;
        value.status = TomatoClockStatus.working;
      } else {
        value.status = TomatoClockStatus.resting;
      }

      if (value.totalSeconds % 30 == 0) {
        ++value.tomatoCount;
      }

      value.currentCycleSeconds = (value.currentCycleSeconds + 1) % 30;

      notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
    value = TomatoClockValue();
    notifyListeners();
  }
}

enum TomatoClockStatus { working, resting }

class TomatoClockValue {
  int totalSeconds;
  int totalLearningSeconds;
  int tomatoCount;
  int currentCycleSeconds;
  bool isRunning;
  TomatoClockStatus status;

  TomatoClockValue(
      {this.totalSeconds = 0,
      this.totalLearningSeconds = 0,
      this.currentCycleSeconds = 0,
      this.tomatoCount = 0,
      this.isRunning = false,
      this.status = TomatoClockStatus.working});

  TomatoClockValue copyWith(
      {int? totalSeconds,
      int? totalLearningSeconds,
      int? currentCycleSeconds,
      int? tomatoCount,
      bool? isRunning,
      TomatoClockStatus? status}) {
    return TomatoClockValue(
        totalSeconds: totalSeconds ?? this.totalSeconds,
        totalLearningSeconds: totalLearningSeconds ?? this.totalLearningSeconds,
        currentCycleSeconds: currentCycleSeconds ?? this.currentCycleSeconds,
        tomatoCount: tomatoCount ?? this.tomatoCount,
        isRunning: isRunning ?? this.isRunning,
        status: status ?? this.status);
  }
}
