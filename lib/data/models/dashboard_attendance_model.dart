/// Attendance item model for dashboard display
class DashboardAttendanceModel {
  final String name;
  final String date;
  final String jamMasuk;
  final String jamKeluar;
  final String status;

  DashboardAttendanceModel({
    required this.name,
    required this.date,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.status,
  });

  factory DashboardAttendanceModel.fromJson(Map<String, dynamic> json) {
    return DashboardAttendanceModel(
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      jamMasuk: json['jamMasuk'] ?? '-',
      jamKeluar: json['jamKeluar'] ?? '-',
      status: json['status'] ?? 'Hadir',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'jamMasuk': jamMasuk,
      'jamKeluar': jamKeluar,
      'status': status,
    };
  }

  /// For mock data creation
  static DashboardAttendanceModel createMock({
    required String name,
    required String date,
    required String jamMasuk,
    String jamKeluar = '-',
    String status = 'Hadir',
  }) {
    return DashboardAttendanceModel(
      name: name,
      date: date,
      jamMasuk: jamMasuk,
      jamKeluar: jamKeluar,
      status: status,
    );
  }
}
