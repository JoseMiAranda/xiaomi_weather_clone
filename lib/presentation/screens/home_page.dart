import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  static const String name = '/';
  const HomePage({super.key});

  bool isMobile() {
    return !(kIsWeb ||
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS));
  }

  @override
  Widget build(BuildContext context) {
    return isMobile()
        ? const AutoRouter()
        : SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: const Center(
                child: SizedBox(
                  width: 411.42,
                  height: 890.28,
                  child: AutoRouter(),
                ),
              ),
            ),
          );
  }
}
