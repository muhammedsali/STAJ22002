import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/status_badge.dart';
import 'approval_review_screen.dart';

class ApprovalQueueScreen extends ConsumerWidget {
  const ApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF002244);

    // Mock Veri: Sadece inceleme bekleyenler
    final List<Map<String, dynamic>> pendingApprovals = [
      {
        'id': 'TR-2026-001',
        'title': 'Ankara Merkez Trafo Yenileme',
        'applicant': 'Ahmet Yılmaz',
        'date': '30 Ağustos 2026',
        'status': 'kademe1',
      },
      {
        'id': 'TR-2026-005',
        'title': 'Organize Sanayi Bölgesi İlave Hat',
        'applicant': 'Mehmet Demir',
        'date': '29 Ağustos 2026',
        'status': 'kademe2',
      }
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Onay Kuyruğu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingApprovals.length,
        itemBuilder: (context, index) {
          final project = pendingApprovals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApprovalReviewScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(project['id'], style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        StatusBadge(status: project['status']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(project['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(project['applicant'], style: TextStyle(color: Colors.grey.shade700)),
                        const Spacer(),
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(project['date'], style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                    const Divider(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ApprovalReviewScreen()),
                          );
                        },
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('İncele ve Karar Ver'),
                        style: TextButton.styleFrom(foregroundColor: Colors.orange.shade700),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}