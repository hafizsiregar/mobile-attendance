import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationManager {
  static const String _masterLocationKey = 'master_location';

  Future saveMasterLocation(Position position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(position.toJson());
    await prefs.setString(_masterLocationKey, json);
  }

  Future<Position?> getMasterLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString(_masterLocationKey);
    if (json != null) {
      Map<String, dynamic> map = jsonDecode(json);
      return Position.fromMap(map);
    }
    return null;
  }
}
