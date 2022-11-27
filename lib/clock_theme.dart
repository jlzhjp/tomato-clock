import 'dart:ui';

class ClockTheme {
  final Color? fabBackground;
  final Color? fabForeground;
  final Color workingPeriodColor;
  final Color restingPeriodColor;
  final Color maskTintColor;

  ClockTheme(
      {this.fabBackground,
      this.fabForeground,
      required this.workingPeriodColor,
      required this.restingPeriodColor,
      required this.maskTintColor});
}
