import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_attendance/attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  // Fungsi untuk menambahkan data kehadiran
  Future addAttendance(double latitude, double longitude) async {
    DateTime currentTime = DateTime.now();
    Attendance attendance = Attendance(
      time: currentTime,
      latitude: latitude,
      longitude: longitude,
    );

    // Simpan data kehadiran ke penyimpanan lokal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> attendanceList = prefs.getStringList('attendance') ?? [];
    attendanceList.add(jsonEncode({
      'time': attendance.time.toIso8601String(),
      'latitude': attendance.latitude,
      'longitude': attendance.longitude,
    }));
    await prefs.setStringList('attendance', attendanceList);
  }

  // Fungsi untuk melakukan pengecekan kehadiran berdasarkan lokasi master
  Future checkAttendance(Position masterPosition) async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    double distanceInMeters = Geolocator.distanceBetween(
      masterPosition.latitude,
      masterPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distanceInMeters > 50) {
      throw Exception('You are too far from the master location.');
    }

    // Jika lokasi sesuai, tambahkan data kehadiran
    await addAttendance(currentPosition.latitude, currentPosition.longitude);
  }
}
