import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_attendance/location_manager.dart';
import 'package:mobile_attendance/attendance_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? masterLocation;
  String? currentLocation;
  LocationManager locationManager = LocationManager();
  AttendanceService attendanceService = AttendanceService();

  Future<void> _takeAttendance() async {
    if (!(await _checkLocationPermission())) {
      // Jika izin lokasi belum diberikan, minta izin lokasi
      await _requestLocationPermission();
      return;
    }

    // Lanjutkan untuk mengambil lokasi
    Position position;
    try {
      position = await _getCurrentLocation();
    } catch (e) {
      _showErrorDialog('Error getting current location');
      return;
    }
    setState(() {
      currentLocation =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
    try {
      await attendanceService.checkAttendance(position);
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<bool> _checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // Izin lokasi diberikan, lanjutkan dengan mengambil lokasi
      _takeAttendance();
    } else {
      // Izin lokasi ditolak, tampilkan pesan kesalahan
      _showErrorDialog('Location permission denied');
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _setMasterLocation() async {
    Position position = await _getCurrentLocation();
    await locationManager.saveMasterLocation(position);
    setState(() {
      masterLocation =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Master location set successfully'),
      ),
    );
  }

  Future _loadMasterLocation() async {
    Position? position = await locationManager.getMasterLocation();
    setState(() {
      masterLocation =
          'Latitude: ${position?.latitude}, Longitude: ${position?.longitude}';
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMasterLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Master Location: ${masterLocation ?? "Not set"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _takeAttendance();
              },
              child: const Text('Take Attendance'),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Location: ${currentLocation ?? "Not available"}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _setMasterLocation();
        },
        tooltip: 'Set Master Location',
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
