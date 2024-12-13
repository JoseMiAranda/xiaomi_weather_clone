import 'package:flutter/material.dart';

class FadeWidget extends StatelessWidget {
  final double transparencyRate;
  final Widget child;
  const FadeWidget({
    super.key,
    required this.transparencyRate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: transparencyRate > 0,
      child: Opacity(
        opacity: transparencyRate,
        child: child,
      ),
    );
  }
}
