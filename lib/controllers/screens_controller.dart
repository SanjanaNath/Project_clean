import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../core/api_config.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';

class ScreenController extends ChangeNotifier {
  String? selectedSiteName;
  String? selectedBlockName;
  Site? selectedSite;
  LocalDatabase localDatabase = LocalDatabase();
  bool isAttendanceMarked = false;

  final List<Site> sites = [];

  final List<PhotoCategory> photoCategories = [
    PhotoCategory(name: 'Entrance', icon: Icons.home_work_rounded),
    PhotoCategory(name: 'Kitchen', icon: Icons.restaurant_menu_rounded),
    PhotoCategory(name: 'Bathroom & Toilet', icon: Icons.wc_rounded),
    PhotoCategory(name: 'Room', icon: Icons.hotel_rounded),
  ];
  final List<BlockList> blocks = [];
  final Map<String, List<File>> capturedImages = {};

  void selectSite(String siteName) {
    selectedSiteName = siteName;
    selectedSite = sites.firstWhere((site) => site.hostelName == siteName);
    isAttendanceMarked = false;
    notifyListeners();
  }
  void clearSelectedSite() {
    selectedSiteName = null;
    selectedSite = null;
    isAttendanceMarked = false;
    notifyListeners();
  }


  Future<void> markAttendance(BuildContext context, String hostelID ,  String hostelName) async {
    if (selectedSite == null) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, "Location permission is required", Colors.green);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(context, "Enable location from settings", Colors.green);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      selectedSite!.lat,
      selectedSite!.lng,
    );

    // if (distance <= 100) {
    //   isAttendanceMarked = true;
    //   _showSnackBar(context, "Attendance marked!", Colors.green);
    // } else {
    //   _showSnackBar(
    //       context,
    //       "You are too far from $selectedSiteName (Distance: ${distance.toStringAsFixed(2)} m)",
    //       Colors.red);
    // }
    hostelAttendance(context: context, hostelID: hostelID, hostelName: hostelName).whenComplete(() {
      isAttendanceMarked = true;
    },);

    notifyListeners();
  }

  void updateImages(String category, List<File> images) {
    capturedImages[category] = images;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  bool isLoading = false;

  Future<void> hostelAttendance({
    required BuildContext context,
    required String hostelID,
    required String hostelName,
  })
  async {
    isLoading = true;
    notifyListeners();

    var body = {
      "user_id": localDatabase.userID,
      "hostel_id": hostelID,
      "hostel_name": hostelName,
      "attendanceStatus":"P"
    };


    try {
      final response = await ApiService().post(ApiConfig.hostelAttendance, body);

      if (response['success'] == true) {
        isAttendanceMarked = true;
        LocalDatabase().setAttendanceID(response['attendance_id']);
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );

        isLoading = false;
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      isLoading = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///Block List API
  Future<void> fetchBlock({
    required BuildContext context,
  })
  async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConfig.blockList);

      if (response['success'] == true) {
        final List dataList = response['data'];


        blocks.clear();
        blocks.addAll(
          dataList.map((item) => BlockList(
            blockName: item['block_name'] ?? '',
            blockCode: item['block_code_lgd'] ?? 0,
          )),
        );



      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to fetch Data",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHostelList({
    required BuildContext context,
    required int blockCode,
  })
  async {
    isLoading = true;
    notifyListeners();

    var body = {
      "block_cd": blockCode,
    };


    try {
      final response = await ApiService().post(ApiConfig.hostelList, body);

      if (response['success'] == true) {
        final List dataList = response['data'];


        sites.clear();
        sites.addAll(
          dataList.map((item) => Site(
            hostelID: item['hostel_id'] ?? '',
            hostelName: item['hostel_name'] ?? 0,
            lat: item['latitude'] ?? 0,
            lng: item['longitude'] ?? 0,
          )),
        );

      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to fetch Data",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPhotos(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();


      var body = {
        "attendance_id": localDatabase.attendanceID,
        "remarks": "ok",
      };

      // Prepare files map
      Map<String, List<File>> files = {
        "Entrance_images": [],
        "Kitchen_images": [],
        "Toilet_images": [],
        "Room_images": [],
      };

      // Fill files map from capturedImages
      capturedImages.forEach((categoryName, images) {
        switch (categoryName) {
          case "Entrance":
            files["Entrance_images"] = images;
            break;
          case "Kitchen":
            files["Kitchen_images"] = images;
            break;
          case "Toilet":
            files["Toilet_images"] = images;
            break;
          case "Room":
            files["Room_images"] = images;
            break;
        }
      });

      // Send all files in one call
      await ApiService().uploadImages(
        ApiConfig.imageUpload,
        extraData: body,
        multipleImages: files,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photos submitted successfully!")),
      );

      capturedImages.clear();
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}

class BlockList {
  final String blockName;
  final int blockCode;


  BlockList({required this.blockName, required this.blockCode,});
}

class Site {
  final String hostelName;
  final String hostelID;
  final double lat;
  final double lng;

  Site({required this.hostelName, required this.lat,required this.hostelID, required this.lng});
}


class PhotoCategory {
  final String name;
  final IconData icon;

  PhotoCategory({required this.name, required this.icon});
}
