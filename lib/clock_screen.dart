import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tomato_clock/tomato_clock.dart';
import 'package:tomato_clock/zoom_out_animation.dart';

import 'clock_theme.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ClockScreenState();
  }
}

// 尝试实现 Material You 那种效果，根据背景图片颜色生成主题
// 可以略过……
ClockTheme _generateClockTheme(
    PaletteGenerator palette, Brightness brightness, ThemeData theme) {
  if (brightness == Brightness.dark) {
    return ClockTheme(
        fabBackground: palette.lightVibrantColor?.color ??
            theme.floatingActionButtonTheme.backgroundColor,
        fabForeground: palette.lightVibrantColor?.bodyTextColor ??
            theme.floatingActionButtonTheme.foregroundColor,
        workingPeriodColor:
            palette.lightVibrantColor?.color ?? Colors.red.shade400,
        restingPeriodColor:
            palette.darkMutedColor?.color ?? Colors.green.shade400,
        maskTintColor: Colors.black);
  } else {
    return ClockTheme(
        fabBackground: palette.darkVibrantColor?.color ??
            theme.floatingActionButtonTheme.backgroundColor,
        fabForeground: palette.darkVibrantColor?.bodyTextColor ??
            theme.floatingActionButtonTheme.foregroundColor,
        workingPeriodColor:
            palette.darkVibrantColor?.color ?? Colors.red.shade400,
        restingPeriodColor:
            palette.lightMutedColor?.color ?? Colors.green.shade400,
        maskTintColor: Colors.white);
  }
}

class _ClockScreenState extends State<ClockScreen>
    with SingleTickerProviderStateMixin {
  late final Future<PaletteGenerator> _paletteGenerator;

  late final AnimationController _animationController =
      AnimationController(duration: const Duration(seconds: 1), vsync: this);

  final TomatoClockController _controller = TomatoClockController();
  bool _isStopped = true;

  @override
  void initState() {
    super.initState();
    _paletteGenerator = PaletteGenerator.fromImageProvider(
        const AssetImage('assets/background.png'));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _paletteGenerator,
      builder: ((context, AsyncSnapshot<PaletteGenerator> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            throw snapshot.error!;
          }
          final media = MediaQuery.of(context);
          final theme = Theme.of(context);

          final clockTheme = _generateClockTheme(
              snapshot.data!, media.platformBrightness, theme);

          return Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: clockTheme.fabBackground,
                foregroundColor: clockTheme.fabForeground,
                onPressed: (() {
                  if (_isStopped) {
                    _animationController.forward();
                    _controller.start();
                  } else {
                    _animationController.reverse();
                    _controller.stop();
                  }
                  setState(() {
                    _isStopped = !_isStopped;
                  });
                }),
                icon: Icon(
                    _isStopped ? Icons.play_arrow_rounded : Icons.stop_rounded),
                label: Text(_isStopped ? "START" : "STOP"),
              ),
              body: Stack(children: [
                Positioned.fill(
                  child: ZoomOutAnimation(
                      animation: _animationController,
                      tintColor: clockTheme.maskTintColor,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: clockTheme.maskTintColor.withAlpha(155)),
                        position: DecorationPosition.foreground,
                        child: const Image(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 350,
                          child: TomatoClock(
                            workingColor: clockTheme.workingPeriodColor,
                            restingColor: clockTheme.restingPeriodColor,
                            controller: _controller,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: ValueListenableBuilder<TomatoClockValue>(
                                    valueListenable: _controller,
                                    builder: ((context, value, child) {
                                      return Text(
                                        value.tomatoCount.toString(),
                                        style: TextStyle(
                                            color: clockTheme.fabBackground,
                                            fontSize: 40),
                                      );
                                    })),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]));
        } else {
          return DecoratedBox(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: const Center(
                child: CircularProgressIndicator(),
              ));
        }
      }),
    );
  }
}
