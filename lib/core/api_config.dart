class ApiConfig {
  ///Local Database Configurations..
  static const String databaseName = 'database';
  static const apiVersion = "api/v1/"; //local
  // static const apiVersion = "api/v3/"; //live
  static const ip = "192.168.1.4";

  /// Host Url
  static const baseUrl = "http://$ip:5000/$apiVersion/"; //local
  static const baseUrl1 = "http://$ip:5000"; //local


  /// Live Server
// static const baseUrl = "https://vsk.cg.gov.in/cp/$apiVersion";//production
// static const baseUrl1 = "https://vsk.cg.gov.in/cp";//production

  ///Apis
  static const login = "auth/login";
  static const register = "auth/register";
  static const blockList = "hostel/getBlockList";
  static const hostelList = "hostel/getHostelNameByBlock";
  static const hostelAttendance = "hostel/hostel-attendance";
  static const imageUpload = "hostel/uploadImages";
  static const getUserAttendance = "hostel/attendance/user/";
  static const getUserReport = "hostel/getReportById/";



  ///Admin DashBoard
static const getHostelReportByDate = "hostel/hostelReportByDate";
static const getZeroLeastHostels = "hostel/zeroLeastHostels";
static const getOfficers = "hostel/getOfficers";
static const getHostel = "hostel/getHostelAttendanceSummary";
static const getOfficerDetails = "hostel/attendance/user/";
static const getHostelDetails = "hostel/getAttendanceByHostelId/";

}