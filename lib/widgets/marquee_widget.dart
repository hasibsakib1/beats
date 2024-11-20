import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeWidget extends StatelessWidget {
  const MarqueeWidget({super.key, required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: style,
      scrollAxis: Axis.horizontal,
      blankSpace: 20.0,
      velocity: 30.0,
      startAfter: const Duration(seconds: 3),
      pauseAfterRound: const Duration(seconds: 3),
      // startPadding: 10.0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
