import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlWidget extends StatelessWidget {
  final String url;
  final Widget child;

  const UrlWidget({super.key, required this.url, required this.child});

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchInBrowser(Uri.parse(url));
      },
      child: child,
    );
  }
}
