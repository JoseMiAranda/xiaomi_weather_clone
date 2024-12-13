import 'package:flutter/material.dart';

class NoGlowScroll extends StatelessWidget {
  final ScrollView child;
  const NoGlowScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: child,
    );
  }
}
