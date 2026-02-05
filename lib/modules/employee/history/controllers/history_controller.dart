import 'package:get/get.dart';

class HistoryController extends GetxController {
  final attendanceCount = 20.obs;
  final izinCount = 2.obs;
  final sakitCount = 1.obs;
  
  final selectedFilter = 'Semua'.obs;
  final searchQuery = ''.obs;
  
  final allAttendances = <Map<String, dynamic>>[].obs;
  final filteredAttendances = <Map<String, dynamic>>[].obs;

  final filters = ['Semua', 'Hadir', 'Izin', 'Sakit'];

  @override
  void onInit() {
    super.onInit();
    _loadAttendanceHistory();
  }

  void _loadAttendanceHistory() {
    // Mock data - replace with API call
    allAttendances.value = [
      {
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Hadir',
      },
      {
        'date': '20/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '17:00',
        'status': 'Sakit',
      },
      {
        'date': '19/01/2026',
        'jamMasuk': '08:15',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
      {
        'date': '18/01/2026',
        'jamMasuk': '-',
        'jamKeluar': '-',
        'status': 'Izin',
      },
      {
        'date': '17/01/2026',
        'jamMasuk': '07:55',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
    ];
    _applyFilter();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    var result = allAttendances.toList();

    // Apply status filter
    if (selectedFilter.value != 'Semua') {
      result = result.where((a) => a['status'] == selectedFilter.value).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      result = result.where((a) => 
        a['date'].toString().contains(searchQuery.value) ||
        a['status'].toString().toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    filteredAttendances.value = result;
  }
}
