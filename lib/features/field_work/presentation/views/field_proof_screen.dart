import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FieldProofScreen extends StatefulWidget {
  final String jobId;

  const FieldProofScreen({super.key, required this.jobId});

  @override
  State<FieldProofScreen> createState() => _FieldProofScreenState();
}

class _FieldProofScreenState extends State<FieldProofScreen> {
  final List<Offset?> _signaturePoints = [];
  final List<String> _uploadedImages = [
    'HVAC_Unit_Serial_Plate.jpg',
    'Pressure_Gauge_Reading_98psi.jpg',
  ];

  bool _isSignatureSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.accentEmerald, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Field Proof & Sign-Off (${widget.jobId})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Images • E-Signature • Work Verification',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.accentEmerald,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Upload Images / Photo Proof
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Work Verification Images',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: _simulateImageUpload,
                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                  label: const Text('Capture Photo', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image Thumbnails Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: _uploadedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _uploadedImages.length) {
                  return InkWell(
                    onTap: _simulateImageUpload,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.accent, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, color: AppColors.accent, size: 28),
                          SizedBox(height: 6),
                          Text(
                            'Add Image Proof',
                            style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final imgName = _uploadedImages[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_rounded, color: AppColors.accentEmerald, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        imgName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Geo-Tagged • 1080p',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Section 2: Interactive Digital E-Signature Screen Pad
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Digital Signature',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _signaturePoints.clear();
                      _isSignatureSaved = false;
                    });
                  },
                  icon: const Icon(Icons.clear_rounded, color: AppColors.accentRose, size: 16),
                  label: const Text('Clear Pad', style: TextStyle(color: AppColors.accentRose, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Signature Canvas Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isSignatureSaved ? AppColors.accentEmerald : AppColors.accent,
                  width: 1.5,
                ),
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  setState(() {
                    _signaturePoints.add(localPosition);
                  });
                },
                onPanEnd: (details) {
                  _signaturePoints.add(null);
                },
                child: CustomPaint(
                  painter: _SignaturePainter(points: _signaturePoints),
                  size: Size.infinite,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Draw sign with finger on screen',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSignatureSaved ? AppColors.accentEmerald : AppColors.technicianRole,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSignatureSaved = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer E-Signature saved and attached to report!'),
                        backgroundColor: AppColors.accentEmerald,
                      ),
                    );
                  },
                  icon: Icon(_isSignatureSaved ? Icons.check_circle_rounded : Icons.save_rounded, size: 16),
                  label: Text(_isSignatureSaved ? 'Signature Saved' : 'Save Signature'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Complete Work Sign Off Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentEmerald),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job Work Completed & Verified with Customer Signature!'),
                      backgroundColor: AppColors.accentEmerald,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text('Complete & Submit Sign-Off', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateImageUpload() {
    setState(() {
      _uploadedImages.add('Photo_Proof_${_uploadedImages.length + 1}.jpg');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo proof captured and attached to job report.')),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
