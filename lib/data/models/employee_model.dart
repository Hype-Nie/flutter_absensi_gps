/// Employee model for admin dashboard
class EmployeeModel {
  final String id;
  final String name;
  final String npk;
  final String position;
  final String department;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.npk,
    required this.position,
    required this.department,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    // Handle both API response field names ('nama') and local field names ('name')
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['nama'] ?? json['name'] ?? '',
      npk: json['npk'] ?? '',
      position: json['position'] ?? 'Staff',
      department: json['department'] ?? '-',
      role: json['role'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Create from API register response
  factory EmployeeModel.fromRegisterResponse(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? {};
    return EmployeeModel(
      id: user['id']?.toString() ?? '',
      name: user['nama'] ?? '',
      npk: user['npk'] ?? '',
      position: 'Staff',
      department: '-',
      role: user['role'],
      createdAt: DateTime.tryParse(user['created_at']),
      updatedAt: DateTime.tryParse(user['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'npk': npk,
      'position': position,
      'department': department,
      if (role != null) 'role': role,
    };
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'npk': npk,
      'nama': name,
      'position': position,
      'department': department,
      'role': role ?? 'karyawan',
    };
  }

  /// For mock data creation
  static EmployeeModel createMock({
    required String id,
    required String name,
    required String npk,
    required String position,
    required String department,
    String? role,
  }) {
    return EmployeeModel(
      id: id,
      name: name,
      npk: npk,
      position: position,
      department: department,
      role: role,
    );
  }

  /// CopyWith method for updates
  EmployeeModel copyWith({
    String? id,
    String? name,
    String? npk,
    String? position,
    String? department,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      npk: npk ?? this.npk,
      position: position ?? this.position,
      department: department ?? this.department,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
