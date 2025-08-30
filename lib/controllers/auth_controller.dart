import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/api_config.dart';
import '../services/api_service.dart';
import '../services/local_database.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;


  ///login API
  Future<void> login({
    required BuildContext context,
    required String password,
    required String email,
  })
  async {

    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    var body = {
      "email": email,
      "password": password,
    };

    debugPrint('Sent Data is $body');

    try {
      final response = await ApiService().post(
        ApiConfig.login,
        body,
      );

      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        LocalDatabase().setAccessToken(response['data']['token']);
        LocalDatabase().setRole(response['data']['user']['role_id']);
        LocalDatabase().setUserName(response['data']['user']['name']);
        LocalDatabase().setUserID(response['data']['user']['user_id']);
        LocalDatabase().setLoginStatus("LoggedIn");

        response['data']['user']['role_id'] == 2 ?
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,):
        Navigator.pushNamedAndRemoveUntil(context, '/adminDashboard', (route) => false,);
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Registration failed",
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


  ///Register API
  Future<void> register({
    required BuildContext context,
    required String name,
    required String password,
    required String mobile,
    required String email,
  })
  async {

    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    var body = {
      "name": name,
      "email": email,
      "password": password,
      "role_id": "2",
      "contact": mobile,
      "address": "test"
    };

    debugPrint('Sent Data is $body');

    try {
      final response = await ApiService().post(
        ApiConfig.register,
        body,
      );

      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        isLoading = false;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false,);

      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Registration failed",
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


  ///Change Password API
  Future<void> changePassword({
    required BuildContext context,
    required String newPassword,
    required String mobile,

  })
  async {

    FocusScope.of(context).unfocus();
    isLoading = true;
    notifyListeners();

    var body = {
      "identifier": mobile,
      "newPassword": newPassword,
    };

    debugPrint('Sent Data is $body');

    try {
      final response = await ApiService().post(
        ApiConfig.changePassword,
        body,
      );

      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: response['message'],
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false,);

      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Registration failed",
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


}