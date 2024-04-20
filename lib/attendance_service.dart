import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_attendance/attendance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  Future addAttendance(double latitude, double longitude) async {
    DateTime currentTime = DateTime.now();
    Attendance attendance = Attendance(
      time: currentTime,
      latitude: latitude,
      longitude: longitude,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> attendanceList = prefs.getStringList('attendance') ?? [];
    attendanceList.add(jsonEncode({
      'time': attendance.time.toIso8601String(),
      'latitude': attendance.latitude,
      'longitude': attendance.longitude,
    }));
    await prefs.setStringList('attendance', attendanceList);
  }

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

    await addAttendance(currentPosition.latitude, currentPosition.longitude);
  }
}
