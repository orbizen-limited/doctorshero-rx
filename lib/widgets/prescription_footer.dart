import 'package:flutter/material.dart';

class PrescriptionFooter extends StatelessWidget {
  final String doctorName;
  final String bio;
  final VoidCallback? onSaveAndPrint;
  final VoidCallback? onPrintOnly;

  const PrescriptionFooter({
    Key? key,
    this.doctorName = 'Dr. John Doe',
    this.bio = 'MBBS, FCPS',
    this.onSaveAndPrint,
    this.onPrintOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Action Buttons
          Row(
            children: [
              if (onSaveAndPrint != null)
                ElevatedButton.icon(
                  onPressed: onSaveAndPrint,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save and Print'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE3001),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              if (onSaveAndPrint != null && onPrintOnly != null) const SizedBox(width: 12),
              if (onPrintOnly != null)
                OutlinedButton.icon(
                  onPressed: onPrintOnly,
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFE3001),
                    side: const BorderSide(color: Color(0xFFFE3001)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
          // Signature
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 200,
                height: 1,
                color: const Color(0xFF1E293B),
              ),
              const SizedBox(height: 8),
              Text(
                doctorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  fontFamily: 'ProductSans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bio,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontFamily: 'ProductSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
