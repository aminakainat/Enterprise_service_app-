import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/deeplink_model.dart';
import '../controllers/deeplink_providers.dart';

class DeepLinkTesterDialog extends ConsumerStatefulWidget {
  const DeepLinkTesterDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const DeepLinkTesterDialog(),
    );
  }

  @override
  ConsumerState<DeepLinkTesterDialog> createState() =>
      _DeepLinkTesterDialogState();
}

class _DeepLinkTesterDialogState extends ConsumerState<DeepLinkTesterDialog> {
  final _urlController = TextEditingController(text: 'fieldservice://job/JOB-2041');

  final List<String> _sampleDeepLinks = [
    'fieldservice://job/JOB-2041',
    'fieldservice://notification/NOTIF-882',
    'fieldservice://customer/CUST-802',
    'fieldservice://report/REP-9042',
  ];

  @override
  Widget build(BuildContext context) {
    final deepLinkState = ref.watch(deepLinkControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.link_rounded, color: AppColors.accent),
                  SizedBox(width: 10),
                  Text(
                    'Deep Link Tester & Router',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Test URI schemes for opening specific jobs, notifications, customers, and reports.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // URL Input
          TextFormField(
            controller: _urlController,
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: 'Deep Link URL',
              hintText: 'fieldservice://job/JOB-2041',
              prefixIcon: const Icon(Icons.travel_explore_rounded, color: AppColors.accent),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 28),
                onPressed: () => _executeDeepLink(_urlController.text.trim()),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preset Buttons
          const Text(
            'Quick Sample Deep Links:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sampleDeepLinks.map((url) {
              return ActionChip(
                backgroundColor: AppColors.surfaceCard,
                side: const BorderSide(color: AppColors.border),
                avatar: Icon(_getIconForUrl(url), size: 14, color: AppColors.accent),
                label: Text(
                  url.replaceAll('fieldservice://', ''),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _urlController.text = url;
                  _executeDeepLink(url);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          if (deepLinkState.deepLinkHistory.isNotEmpty) ...[
            const Text(
              'Recent Deep Link Invocations:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                itemCount: deepLinkState.deepLinkHistory.length,
                itemBuilder: (ctx, i) {
                  final item = deepLinkState.deepLinkHistory[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded, size: 16, color: AppColors.textMuted),
                    title: Text(item, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontFamily: 'monospace')),
                    onTap: () {
                      _urlController.text = item;
                      _executeDeepLink(item);
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getIconForUrl(String url) {
    if (url.contains('job')) return Icons.assignment_rounded;
    if (url.contains('notification')) return Icons.notifications_active_rounded;
    if (url.contains('customer')) return Icons.person_pin_rounded;
    if (url.contains('report')) return Icons.receipt_long_rounded;
    return Icons.link_rounded;
  }

  void _executeDeepLink(String url) {
    final parsed = ref.read(deepLinkControllerProvider.notifier).handleDeepLinkUrl(url);

    Navigator.of(context).pop(); // Close tester dialog

    // Open target modal based on parsed type
    switch (parsed.type) {
      case DeepLinkType.job:
        _showJobDeepLinkModal(context, parsed.targetId);
        break;
      case DeepLinkType.notification:
        _showNotificationDeepLinkModal(context, parsed.targetId);
        break;
      case DeepLinkType.customer:
        _showCustomerDeepLinkModal(context, parsed.targetId);
        break;
      case DeepLinkType.report:
        _showReportDeepLinkModal(context, parsed.targetId);
        break;
      case DeepLinkType.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown deep link URI: $url')),
        );
        break;
    }
  }

  void _showJobDeepLinkModal(BuildContext context, String jobId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text('DEEP LINKED JOB • $jobId', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            const Text('HVAC Air Handler Repair & Calibration', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Customer: Nexus Tech Plaza (Floor 4)', style: TextStyle(color: AppColors.textSecondary)),
            const Text('Address: 742 Cyber Way, Suite 400', style: TextStyle(color: AppColors.textSecondary)),
            const Text('Status: In Progress • High Priority', style: TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Open Job Terminal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDeepLinkModal(BuildContext context, String notifId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: AppColors.accentAmber),
                const SizedBox(width: 10),
                Text('DEEP LINKED NOTIFICATION • $notifId', style: const TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('High Priority Dispatch Alert', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Dispatcher assigned Emergency Generator Inspection at Metro Health Hospital.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Acknowledge Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerDeepLinkModal(BuildContext context, String customerId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business_rounded, color: AppColors.accentEmerald),
                const SizedBox(width: 10),
                Text('CUSTOMER PROFILE • $customerId', style: const TextStyle(color: AppColors.accentEmerald, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Aero Dynamics HQ (Commercial Tier 1)', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Contact: Marcus Vance (Operations Lead)', style: TextStyle(color: AppColors.textSecondary)),
            const Text('Phone: +1 (555) 019-2834', style: TextStyle(color: AppColors.textSecondary)),
            const Text('Address: 120 Innovation Blvd', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Call Customer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDeepLinkModal(BuildContext context, String reportId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.adminRole),
                const SizedBox(width: 10),
                Text('DEEP LINKED REPORT • $reportId', style: const TextStyle(color: AppColors.adminRole, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Field Audit & Service Report', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Status: Completed & Signed • Total: \$385.00', style: TextStyle(color: AppColors.accentEmerald, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('View Full Printable Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
