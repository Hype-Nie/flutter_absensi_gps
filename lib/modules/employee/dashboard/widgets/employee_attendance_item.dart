import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class EmployeeAttendanceItem extends StatelessWidget {
  final Map<String, dynamic> attendance;

  const EmployeeAttendanceItem({
    super.key,
    required this.attendance,
  });

  Color _getStatusColor() {
    switch (attendance['status']) {
      case 'Hadir':
        return AppColors.success;
      case 'Sakit':
        return AppColors.error;
      case 'Izin':
        return AppColors.warning;
      default:
        return AppColors.grey600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: AppColors.grey500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jam Masuk:  ${attendance['jamMasuk']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
                Text(
                  'Jam Keluar:  ${attendance['jamKeluar']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              attendance['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
