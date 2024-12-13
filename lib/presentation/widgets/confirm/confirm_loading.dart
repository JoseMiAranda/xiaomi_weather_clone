import 'package:flutter/material.dart';

class ConfirmLoading extends StatelessWidget {
  const ConfirmLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}