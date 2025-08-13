import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';

import '../core/api_config.dart';

class LocalDatabase extends ChangeNotifier{
  ///Hive Database Initialization....

  static Future initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(ApiConfig.databaseName);
  }

  ///Hive Database Box....
  Box database = Hive.box(ApiConfig.databaseName);

  ///Access Local Database data...

  late String? userName = database.get('userName');
  late int? userID = database.get('userID');
  late int? attendanceID = database.get('attendanceID');
  late String? accessToken = database.get('accessToken');
  late String? deviceToken = database.get('deviceToken');
  late String? loginStatus = database.get('loginStatus');

  void setUserID(int? id) {
    userID = id;
    database.put('userID', id ?? 0);
    notifyListeners();
  }
  void setAttendanceID(int? attendID) {
    attendanceID = attendID;
    database.put('attendanceID', attendID ?? 0);
    notifyListeners();
  }
  void setUserName(String? name) {
    userName = name;
    database.put('userName', name ?? '');
    notifyListeners();
  }
  setDeviceToken(String? token) {
    deviceToken = token;
    database.put('deviceToken', token ?? '');
    notifyListeners();
  }
  void setAccessToken(String? token) {
    accessToken = token;
    database.put('accessToken', token ?? '');
    notifyListeners();
  }

  setLoginStatus(String? status) {
    loginStatus = status;
    database.put('loginStatus', status ?? '');
    notifyListeners();
  }




}