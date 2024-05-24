import 'dart:math';

import 'package:air_scanner/providers/notifiers/image_notifier.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProcessingAnimation extends StatefulWidget {
  final ImageProcessingState state;
  const ProcessingAnimation({super.key, required this.state});

  @override
  State<ProcessingAnimation> createState() => _ProcessingAnimationState();
}

class _ProcessingAnimationState extends State<ProcessingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProcessingAnimation oldWidget) {
    if (oldWidget.state != widget.state) {
      _controller.value = max(1, widget.state.progress / 100);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedBuilder(
          animation: _controller,
          child: LottieBuilder.asset(
            'assets/processing_animation.json',
            controller: _controller,
          ),
          builder: (context, child) => child!,
        ),
        Text(widget.state.message),
      ],
    );
  }
}
