import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(label, style: const TextStyle(fontSize: 20),), const Spacer(), Text(value, style: const TextStyle(fontSize: 20),)]);
  }
}
