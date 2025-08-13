class ApiConfig {
  ///Local Database Configurations..
  static const String databaseName = 'database';
  static const apiVersion = "api/v1/";

  /// Host Url
  static const baseUrl = "http://10.10.73.235:5000/$apiVersion";//iit
  // static const baseUrl = "http://10.232.59.13:5000/$apiVersion/"; //hotspot
  // static const baseUrl = "http://10.62.1.47:5000/$apiVersion"; //samagra


  /// Live Server
// static const baseUrl = "https://vsk.cg.gov.in/ttms/api/";//production

  ///Apis
  static const login = "auth/login";
  static const register = "auth/register";
  static const blockList = "hostel/getBlockList";
  static const hostelList = "hostel/getHostelNameByBlock";
  static const hostelAttendance = "hostel/hostel-attendance";
  static const imageUpload = "hostel/hostel-attendance";

}