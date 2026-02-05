import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import 'employee_dashboard_controller.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () {
                      // Handle back navigation
                      // If this is the main dashboard, maybe it shows a dialog or exits
                      // For now, we follow the wireframe.
                      Get.back(); 
                    },
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pilih Absensi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Body - Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildAbsensiCard(
                    icon: Icons.check_circle_outline,
                    label: 'Hadir',
                    onTap: () {
                      // Navigate to Present/Camera page
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildAbsensiCard(
                    icon: Icons.access_time, // Or update icon to better match "Clock"
                    label: 'Izin',
                    onTap: () {
                      // Navigate to Permission page
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildAbsensiCard(
                    icon: Icons.local_hospital_outlined, // Medical/Person icon
                    label: 'Sakit',
                    onTap: () {
                      // Navigate to Sick page
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[300],
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                '@2026 Perhutani Padangan',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsensiCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120, // Approximate height from wireframe
      decoration: BoxDecoration(
        color: Colors.grey[300], // Matches wireframe gray background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[500]!, width: 3),
                    // color: Colors.grey[400], // Inner circle color if needed
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.grey[600], // Icon color
                  ),
                ),
                const SizedBox(width: 24),
                
                // Text
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 32,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}