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
  // LocalDatabase localDatabase = LocalDatabase();
  bool isAttendanceMarked = false;
  bool isLoading = false;
  final List<Site> sites = [];
  bool isGeneratingReport = false;
  final TextEditingController remarkController = TextEditingController();
  void setGeneratingReport(bool value) {
    isGeneratingReport = value;
    notifyListeners();
  }
  final List<PhotoCategory> photoCategories = [
    PhotoCategory(name: 'Entrance', icon: Icons.home_work_rounded),
    PhotoCategory(name: 'Kitchen', icon: Icons.restaurant_menu_rounded),
    PhotoCategory(name: 'Bathroom & Toilet', icon: Icons.wc_rounded),
    PhotoCategory(name: 'Room', icon: Icons.hotel_rounded),
  ];
  final List<BlockList> blocks = [];
  final List<QuestionList> questionList = [];
  final List<SurveyHistoryList> surveyHistoryList = [];
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

  final Map<String, dynamic> answers = {};

  void setAnswer(String questionId, dynamic value) {
    answers[questionId] = value;
    notifyListeners();
  }

  // You might also want a method to clear the answers
  void clearAnswers() {
    answers.clear();
    notifyListeners();
  }


  bool get isSurveyComplete {
    // Check if every question has a non-empty answer.
    return questionList.every((question) {
      final answer = answers[question.questionId];

      // Check for null or empty string answers.
      if (answer == null || (answer is String && answer.trim().isEmpty)) {

        return false;
      }
      return true;
    });
  }

  Future<void> markAttendance(BuildContext context, int hostelID_id ,  String hostelName) async {
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
    isLoading = true;
    notifyListeners();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      selectedSite!.lat,
      selectedSite!.lng,
    );

    // if (distance <= 100) {
    //   hostelAttendance(context: context, hostelID: hostelID_id.toString(), hostelName: hostelName).whenComplete(() {
    //     isLoading = false;
    //     isAttendanceMarked = true;
    //   },);
    //   // if (isAttendanceMarked) {
    //   //   _showSnackBar(context, "Attendance marked!", Colors.green);
    //   // }
    // } else {
    //
    //   _showSnackBar(
    //       context,
    //       "You are too far from $selectedSiteName",
    //       Colors.red);
    //   isLoading = false;
    //   // _showSnackBar(
    //   //     context,
    //   //     "You are too far from $selectedSiteName (Distance: ${distance.toStringAsFixed(2)} m)",
    //   //     Colors.red);
    // }

   await  hostelAttendance(context: context, hostelID: hostelID_id.toString(), hostelName: hostelName).whenComplete(() {
      isLoading = false;
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

  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }



  bool get allCategoriesHavePhotos {
    for (var category in photoCategories) {
      if (capturedImages[category.name] == null || capturedImages[category.name]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  ///Mark Attendance API
  Future<void> hostelAttendance({
    required BuildContext context,
    required String hostelID,
    required String hostelName,
  })
  async {
    isLoading = true;
    notifyListeners();

    var body = {
      "user_id": LocalDatabase().userID,
      "hostel_id": hostelID,
      "hostel_name": hostelName,
      "attendanceStatus":"P"
    };


    try {
      final response = await ApiService().post(ApiConfig.hostelAttendance, body);

      if (response['success'] == true) {
        LocalDatabase().setAttendanceID(response['attendance_id']);
        // isAttendanceMarked = true;
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        print("localDatabase.attendanceID ==========>${ LocalDatabase().attendanceID}");
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
        isLoading = false;
        print("localDatabase.attendanceID1 ==========>${ LocalDatabase().attendanceID}");
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


/// Hostel List API
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
            hostelID_id: item["id"] ?? 0,
            hostelID: item['hostel_id'] ?? '',
            hostelName: item['hostel_name'] ?? 0,
            lat: item['latitude'] ?? 0,
            lng: item['longitude'] ?? 0,
          )),
        );

      }
      else {
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


  ///Image Upload API
  Future<void> submitPhotos(BuildContext context, String remark)
  async {
    if (selectedSite == null) {
      _showSnackBar(context, "Please select a site first.", Colors.red);
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, "Location permission is required to submit photos.", Colors.red);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(context, "Enable location from settings to submit photos.", Colors.red);
      return;
    }

    isLoading = true;
    notifyListeners();

      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          selectedSite!.lat,
          selectedSite!.lng,
        );

        // if (distance > 100) {
        //   _showSnackBar(
        //       context,
        //       "You are too far from $selectedSiteName. Can't submit.",
        //       Colors.red);
        //   isLoading = false;
        //   return;
        // }

        var body = {
        "attendance_id": LocalDatabase().attendanceID,
        "remarks": remark,
        "image_type[0]": "Entrance",
        "image_type[1]": "Kitchen",
        "image_type[2]": "Bathroom & Toilet",
        "image_type[3]": "Room",

      };

      // Prepare files map
      Map<String, List<File>> files = {
        "images[0]": [],
        "images[1]": [],
        "images[2]": [],
        "images[3]": [],
      };

      // Fill files map from capturedImages
      capturedImages.forEach((categoryName, images) {
        switch (categoryName) {
          case "Entrance":
            files["images[0]"] = images;
            break;
          case "Kitchen":
            files["images[1]"] = images;
            break;
          case "Bathroom & Toilet":
            files["images[2]"] = images;
            break;
          case "Room":
            files["images[3]"] = images;
            break;
        }
      });
        print("Sent files $files");
        print("Sent Body $body");
      // Send all files in one call
        // Send all files in one call
        final response = await ApiService().uploadImages(
          "${ApiConfig.baseUrl}${ApiConfig.imageUpload}",
          extraData: body,
          multipleImages: files,
        );

        if (response['success'] == true) {
          isLoading = false;
          notifyListeners();
          Fluttertoast.showToast(
            msg: "Inspection Completed successfully!",
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG,
          );
          surveyHistoryList.clear();
           remarkController.clear();
          clearSelectedSite();
          capturedImages.clear();
          notifyListeners();
        } else {
          // Handle API failure response
          Fluttertoast.showToast(
            msg: response['message'] ?? "Photo submission failed.",
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          isLoading = false;

        }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      isLoading = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///Attendance History API
  Future<void> surveyHistory({
    required BuildContext context,
  })
  async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get("${ApiConfig.getUserAttendance}${LocalDatabase().userID}");

      if (response['success'] == true) {
        final List dataList = response['data'];



        surveyHistoryList.addAll(
          dataList.map((item) => SurveyHistoryList(
            attendanceDate: item['attendance_date'] ?? '',
            attendanceID: item['attendance_id'] ?? 0,
            userID: item['user_id'] ?? '',
            hostelName: item['hostel_name'] ?? '',
            hostelID:  item['hostel_id'] ?? ''
          )),
        );


        isLoading = false;
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to fetch Data",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
        isLoading = false;
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


  ///Report Generate API

Future<Map<String, dynamic>?> reportGenerate({
  required BuildContext context,
  required int attendanceID,
})
async {
  isLoading = true;
  notifyListeners();

  try {
    final response = await ApiService().get("${ApiConfig.getUserReport}$attendanceID");

    if (response['success'] == true) {
      return response;
    } else {
      Fluttertoast.showToast(
        msg: response['message'] ?? "Failed to fetch Data",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      return null;
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Error: $e",
      backgroundColor: Colors.red,
      toastLength: Toast.LENGTH_LONG,
    );
    return null;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

/// Question List API
  Future<void> fetchQuestions({
    required BuildContext context,
  })
  async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiConfig.getQuestions);

      if (response['success'] == true) {
        final List dataList = response['data'];
        questionList.clear();
        questionList.addAll(
          dataList.map((e) => QuestionList.fromJson(e)).toList(),
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

  Future<void> submitSurveyAnswers(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      // Convert the 'answers' map to the required list format
      final List<Map<String, dynamic>> answerList = [];
      answers.forEach((questionId, answer) {
        answerList.add({
          "question_id": int.parse(questionId),
          "answer": answer,
        });
      });

      final Map<String, dynamic> body = {
        "attendance_id": LocalDatabase().attendanceID.toString(),
        "answers": answerList,
      };

      final response = await ApiService().post(ApiConfig.submitAnswer, body);

      if (response['success'] == true) {
        clearAnswers();
      } else {
        showSnackBar(context, response['message'] ?? "Failed to submit survey answers.", Colors.red);
      }

    } catch (e) {
      showSnackBar(context, "An error occurred: $e", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}


class QuestionList {
  final String questionId;
  final String questionText;
  final String answerType;
  final List<String>? options; // Now correctly defined as a nullable List

  QuestionList({
    required this.questionId,
    required this.questionText,
    required this.answerType,
    this.options, // This can now be null
  });

  factory QuestionList.fromJson(Map<String, dynamic> json) {
    return QuestionList(
      questionId: json['question_id']?.toString() ?? '',
      questionText: json['question_text'] ?? '',
      answerType: json['answer_type'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'].map((x) => x.toString())) // Correctly handles the list of strings
          : null,
    );
  }
}

class BlockList {
  final String blockName;
  final int blockCode;


  BlockList({required this.blockName, required this.blockCode,});
}
class SurveyHistoryList {
  final String userID;
  final int attendanceID;
  final String hostelName;
  final String hostelID;
  final String attendanceDate;


  SurveyHistoryList({required this.hostelName,required this.hostelID, required this.userID,required this.attendanceID,required this.attendanceDate,});
}

class Site {
  final int hostelID_id;
  final String hostelName;
  final String hostelID;
  final double lat;
  final double lng;

  Site({required this.hostelName, required this.lat,required this.hostelID, required this.lng, required this.hostelID_id});
}


class PhotoCategory {
  final String name;
  final IconData icon;

  PhotoCategory({required this.name, required this.icon});
}
