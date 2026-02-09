/// Employee model for admin dashboard
class EmployeeModel {
  final String id;
  final String name;
  final String npk;
  final String position;
  final String department;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.npk,
    required this.position,
    required this.department,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      npk: json['npk'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'npk': npk,
      'position': position,
      'department': department,
    };
  }

  /// For mock data creation
  static EmployeeModel createMock({
    required String id,
    required String name,
    required String npk,
    required String position,
    required String department,
  }) {
    return EmployeeModel(
      id: id,
      name: name,
      npk: npk,
      position: position,
      department: department,
    );
  }

  /// CopyWith method for updates
  EmployeeModel copyWith({
    String? id,
    String? name,
    String? npk,
    String? position,
    String? department,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      npk: npk ?? this.npk,
      position: position ?? this.position,
      department: department ?? this.department,
    );
  }
}
