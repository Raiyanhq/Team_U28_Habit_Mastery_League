import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InfoCard({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
