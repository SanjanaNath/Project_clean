import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/api_config.dart';
import '../services/api_service.dart';

class DashboardController extends ChangeNotifier {
  bool isLoading = false;
  final List<HostelReportByDate> hostelReportByDate = [];
  final List<Officer> officersList = [];
  final List<Hostel> hostelList = [];
  final List<OfficerDetailList> officerDetailList = [];
  final List<HostelDetailList> hostelDetailList = [];
  int totalReportsCount = 0;
  bool isGeneratingReport = false;
  void setGeneratingReport(bool value) {
    isGeneratingReport = value;
    notifyListeners();
  }
  void setGeneratingReportHome(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchHostelReportByDate({
    required BuildContext context,
    required String date,
    required String month,
    required String from,
    required String to,
  })
  async {
    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    final body = {
      "month": month,
      "from": from,
      "to": to,
      if (date.isNotEmpty) "dates": [date],
      // if (date.isNotEmpty) "dates": ['2025-09-11'],
    };


    debugPrint('Sent Data is $body');

    try {
      final response = await ApiService().post(
        ApiConfig.getHostelReportByDate,
        body,
      );

      if (response['success'] == true) {
        final List dataList = response['data'];

        hostelReportByDate.clear();
        totalReportsCount = response['counts'] ?? 0;
        hostelReportByDate.addAll(
          dataList.map((e) => HostelReportByDate.fromJson(e)).toList(),
        );

        debugPrint("Total reports fetched: ${hostelReportByDate.length}");

        isLoading = false;
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Data fetch failed",
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


  Future<void> zeroLeastHostel({
    required BuildContext context,
    // required String date,
    // required String month,
    // required String from,
    // required String month,
    required String year,
    required String flag,
  })
  async {
    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    var body = {
      // "dates": [date],
      // "month": month,
      "year": year,
      "flag": flag,
      // "from": from,
      // "to": to
    };

    debugPrint('Sent Data is $body');

    try {
      final response = await ApiService().post(
        ApiConfig.getZeroLeastHostels,
        body,
      );

      if (response['success'] == true) {
        final List dataList = response['data'];

        /// Clear old data and add new data
        hostelReportByDate.clear();
        totalReportsCount = response['counts'] ?? 0;
        hostelReportByDate.addAll(
          dataList.map((e) => HostelReportByDate.fromJson(e)).toList(),
        );

        debugPrint("Total reports fetched: ${hostelReportByDate.length}");

        isLoading = false;
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Data fetch failed",
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


///Officer Detail APis
  Future<void> getOfficers({required BuildContext context})
  async {
    isLoading = true;
    notifyListeners();

    try {
      var body = {"":""};

      final response = await ApiService().post(ApiConfig.getOfficers, body );

      if (response['success'] == true) {
        final List dataList = response['data'];

        officersList.clear();
        officersList.addAll(
          dataList.map((e) => Officer.fromJson(e)).toList(),
        );

      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to fetch officers",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching officers: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> getOfficerDetails({required BuildContext context,required String officerID})
  async {
    isLoading = true;
    notifyListeners();

    try {

      final response = await ApiService().get("${ApiConfig.getOfficerDetails}$officerID");


      if (response['success'] == true) {
        final List dataList = response['data'];

        officerDetailList.clear();
        officerDetailList.addAll(
          dataList.map((e) => OfficerDetailList.fromJson(e)).toList(),
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
        msg: "Error fetching Data: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

///Hostel Detail APis
  Future<void> getHostel({required BuildContext context})
  async {
    isLoading = true;
    notifyListeners();

    try {
      var body = {"":""};

      final response = await ApiService().post(ApiConfig.getHostel, body );

      if (response['success'] == true) {
        final List dataList = response['data'];

        hostelList.clear();
        hostelList.addAll(
          dataList.map((e) => Hostel.fromJson(e)).toList(),
        );

      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to fetch Hostel",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching Hostel: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> getHostelDetails({required BuildContext context,required String hostelID})
  async {
    isLoading = true;
    notifyListeners();

    try {

      final response = await ApiService().get("${ApiConfig.getHostelDetails}$hostelID");


      if (response['success'] == true) {
        final List dataList = response['data'];

        hostelDetailList.clear();
        hostelDetailList.addAll(
          dataList.map((e) => HostelDetailList.fromJson(e)).toList(),
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
        msg: "Error fetching Data: $e",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

}


class Officer {
  final int id;
  final String name;
  final String designation;
  final String mobile;

  Officer({
    required this.id,
    required this.name,
    required this.designation,
    required this.mobile,
  });

  factory Officer.fromJson(Map<String, dynamic> json) {
    return Officer(
      id: json['id'],
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}

class Hostel {
  final int hostel_id;
  final String hostel_name;
  final String officers_visited;


  Hostel({
    required this.hostel_id,
    required this.hostel_name,
    required this.officers_visited,

  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      hostel_id: json['hostel_id'] ?? 0,
      hostel_name: json['hostel_name'] ?? '',
      officers_visited: json['officers_visited'] ?? '',

    );
  }
}

class HostelReportByDate {
  final String hostelId;
  final String hostelName;
  final String attendanceDate;
  final String officerNames;
  final String mobiles;
  final String officerId;
  final String officersVisited;

  HostelReportByDate({
    required this.hostelId,
    required this.hostelName,
    required this.attendanceDate,
    required this.officerNames,
    required this.mobiles,
    required this.officerId,
    required this.officersVisited,
  });

  factory HostelReportByDate.fromJson(Map<String, dynamic> json) {
    return HostelReportByDate(
      hostelId: json['hostel_id'].toString(),
      hostelName: json['hostel_name'] ?? '',
      attendanceDate: json['attendance_date'] ?? '',
      officerNames: json['officer_names'] ?? '',
      mobiles: json['mobiles'] ?? '',
      officerId: json['officer_id'] ?? '',
      officersVisited: json['officers_visited'] ?? '0',
    );
  }
}


class OfficerDetailList {
  final String hostelId;
  final String hostelName;
  final String attendanceDate;
  final String attendanceID;
  final String userID;

  OfficerDetailList({
    required this.hostelId,
    required this.hostelName,
    required this.attendanceDate,
    required this.attendanceID,
    required this.userID,
  });

  factory OfficerDetailList.fromJson(Map<String, dynamic> json) {
    return OfficerDetailList(
      hostelId: json['hostel_id'] ?? '',
      hostelName: json['hostel_name'] ?? '',
      attendanceDate: json['attendance_date'] ?? '',
      userID: json['user_id'] ?? '',
      attendanceID: json['attendance_id'].toString() ?? '',
    );
  }
}

class HostelDetailList {
  final String hostelId;
  final String hostelName;
  final String attendanceDate;
  final String attendanceID;
  final String officerName;
  final String officerContact;

  HostelDetailList({
    required this.hostelId,
    required this.hostelName,
    required this.attendanceDate,
    required this.attendanceID,
    required this.officerName,
    required this.officerContact,
  });

  factory HostelDetailList.fromJson(Map<String, dynamic> json) {
    return HostelDetailList(
      hostelId: json['hostel_id'] ?? '',
      hostelName: json['hostel_name'] ?? '',
      attendanceDate: json['attendance_date'] ?? '',
      officerName: json['officer_name'] ?? '',
      attendanceID: json['attendance_id'].toString() ?? '',
      officerContact: json['officer_contact'].toString() ?? '',
    );
  }
}

