import 'package:dio/dio.dart';
import '../models/attendance_history_model.dart';
import '../providers/api_provider.dart';
import '../../core/utils/logger.dart';

/// Service for managing attendance data
class AttendanceService {
  final ApiProvider _apiProvider;

  AttendanceService(this._apiProvider);

  /// Get attendance history by user ID
  /// GET /absensi/{id}
  Future<AttendanceResult> getAttendanceById(String userId) async {
    try {
      AppLogger.info(
        'AttendanceService: Fetching attendance for user ID: $userId',
      );

      final response = await _apiProvider.get('/absensi/$userId');

      AppLogger.info(
        'AttendanceService: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true) {
          final attendanceData = data['data'];

          if (attendanceData is List) {
            // Multiple records
            final attendanceList = attendanceData
                .map(
                  (item) => AttendanceHistoryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

            AppLogger.info(
              'AttendanceService: Found ${attendanceList.length} attendance records',
            );
            return AttendanceResult.success(attendanceList);
          } else if (attendanceData is Map<String, dynamic>) {
            // Single record
            final attendance = AttendanceHistoryModel.fromJson(attendanceData);
            AppLogger.info('AttendanceService: Found 1 attendance record');
            return AttendanceResult.success([attendance]);
          }
        }

        final message = data['message'] ?? 'Gagal memuat data absensi';
        AppLogger.error(
          'AttendanceService: API returned success=false: $message',
        );
        return AttendanceResult.failure(message);
      }

      return AttendanceResult.failure('Gagal memuat data absensi');
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      AppLogger.error('AttendanceService: DioException', e, e.stackTrace);
      return AttendanceResult.failure(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.error('AttendanceService: Unexpected error', e, stackTrace);
      return AttendanceResult.failure('Terjadi kesalahan: ${e.toString()}');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] ?? 'Request failed';
      }
      if (e.response?.statusCode == 404) {
        return 'Data tidak ditemukan';
      }
      if (e.response?.statusCode == 401) {
        return 'Unauthorized - silakan login kembali';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout - periksa koneksi internet Anda';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet';
    }
    return 'Terjadi kesalahan: ${e.message ?? "Unknown error"}';
  }
}

/// Result wrapper for attendance operations
class AttendanceResult {
  final List<AttendanceHistoryModel>? data;
  final String? error;
  final bool isSuccess;

  AttendanceResult._({this.data, this.error, required this.isSuccess});

  factory AttendanceResult.success(List<AttendanceHistoryModel> data) {
    return AttendanceResult._(data: data, isSuccess: true);
  }

  factory AttendanceResult.failure(String error) {
    return AttendanceResult._(error: error, isSuccess: false);
  }
}
