import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final String currentStatus;

  const StepIndicator({super.key, required this.currentStatus});

  // Şartnamedeki durum hiyerarşisi
  final List<String> _steps = const [
    'taslak',
    'gonderildi',
    'on_kontrol',
    'kademe1',
    'kademe2',
    'onaylandi'
  ];

  final Map<String, String> _stepLabels = const {
    'taslak': 'Taslak',
    'gonderildi': 'Gönderildi',
    'on_kontrol': 'Ön Kontrol',
    'kademe1': '1. Kademe',
    'kademe2': '2. Kademe',
    'onaylandi': 'Onaylandı',
  };

  @override
  Widget build(BuildContext context) {
    // Red veya Ek Belge durumlarında özel gösterim yapıyoruz
    bool isRejected = currentStatus == 'reddedildi';
    bool isRevision = currentStatus == 'ek_belge_istendi';
    
    int currentIndex = _steps.indexOf(currentStatus);
    if (currentIndex == -1) {
      if (isRejected || isRevision) {
        currentIndex = 2; // Ön kontrol veya sonrası bir yerde koptuğunu varsayalım
      } else {
        currentIndex = 0;
      }
    }

    return Column(
      children: List.generate(_steps.length, (index) {
        bool isCompleted = index <= currentIndex && !isRejected && !isRevision;
        bool isActive = index == currentIndex;
        bool isError = (isRejected || isRevision) && index == currentIndex;

        Color circleColor = isError 
            ? Colors.red 
            : (isCompleted ? Colors.green : Colors.grey.shade300);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError ? Icons.close : (isCompleted ? Icons.check : Icons.circle),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                if (index != _steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                _stepLabels[_steps[index]] ?? _steps[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isError ? Colors.red : (isActive ? Colors.black87 : Colors.grey.shade600),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}