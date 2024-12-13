import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';
import 'package:xiaomi_weather_clone/presentation/utils/math.dart';
import 'package:xiaomi_weather_clone/presentation/widgets/fade_widget.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class MyCustomAppBar extends StatefulWidget {
  final Widget leading;
  final Widget? trailing;
  final double? height;
  final String text;
  const MyCustomAppBar(
      {super.key,
      required this.leading,
      this.trailing,
      this.height,
      required this.text});

  @override
  State<MyCustomAppBar> createState() => _MyCustomAppBarState();
}

class _MyCustomAppBarState extends State<MyCustomAppBar> {
  bool textTransparent = true;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: MediaQuery.of(context).padding.top + 50,
        maxHeight: 150,
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double scrollRatio = constraints.maxHeight / 150;
                    scrollRatio = scrollRatio.clamp(0.0, 1.0);
          
                    final double transparencyRate = interpolateBetweenPoints(
                      y0: 0,
                      y1: 1,
                      x: scrollRatio,
                      x0: 0.7,
                      x1: 1,
                    ).clamp(0.0, 1.0);
          
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (transparencyRate <= 0.0 && textTransparent) {
                        setState(() {
                          textTransparent = false;
                        });
                      } else if (transparencyRate > 0.0 && !textTransparent) {
                        setState(() {
                          textTransparent = true;
                        });
                      }
                    });
          
                    return FadeWidget(
                      transparencyRate: transparencyRate,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              widget.text,
                              overflow: TextOverflow.ellipsis,
                              style: context.theme.textTheme.headlineLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20,
                    right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.leading,
                    textTransparent
                        ? const SizedBox.shrink()
                        : FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            from: 20,
                            child: Text(
                              widget.text,
                              style: context.theme.textTheme.titleLarge,
                            ),
                          ),
                    widget.trailing ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
