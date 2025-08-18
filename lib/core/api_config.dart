class ApiConfig {
  ///Local Database Configurations..
  static const String databaseName = 'database';
  static const apiVersion = "api/v1/";
  static const ip = "10.62.1.47";//hotspot

  /// Host Url
  static const baseUrl = "http://$ip:5000/$apiVersion/"; //hotspot
  static const baseUrl1 = "http://$ip:5000"; //hotspot


  /// Live Server
// static const baseUrl = "https://vsk.cg.gov.in/ttms/api/";//production

  ///Apis
  static const login = "auth/login";
  static const register = "auth/register";
  static const blockList = "hostel/getBlockList";
  static const hostelList = "hostel/getHostelNameByBlock";
  static const hostelAttendance = "hostel/hostel-attendance";
  static const imageUpload = "hostel/uploadImages";
  static const getUserAttendance = "hostel/attendance/user/";
  static const getUserReport = "hostel/getReportById/";

}