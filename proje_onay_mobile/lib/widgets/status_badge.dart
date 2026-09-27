import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'taslak':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        displayText = 'Taslak';
        break;
      case 'gonderildi':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        displayText = 'Ön Kontrolde';
        break;
      case 'kademe1':
      case 'kademe2':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        displayText = 'İncelemede';
        break;
      case 'onaylandi':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        displayText = 'Onaylandı';
        break;
      case 'reddedildi':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        displayText = 'Reddedildi';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}