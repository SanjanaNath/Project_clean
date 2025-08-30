import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/controllers/auth_controller.dart';
import 'package:project_clean/controllers/screens_controller.dart';
import 'package:project_clean/utils/color_constants.dart';
import 'package:project_clean/widgets/backgroundCircles.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_loader.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  bool _obscureNewRePassword = true;

  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundCircles(
        child: SafeArea(
          child: Stack(
            children: [
              // Back Arrow
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // Go back to login
                  },
                ),
              ),

              // Main Content
              Consumer<AuthController>(
              builder: (context, controller, child) {
                return  ModalProgressHUD(
                  inAsyncCall: controller.isLoading,
                  blur: 2,
                  progressIndicator: CircularProgressIndicator(
                    color: ColorConstants().teal,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 40), // Space after arrow

                            // Title
                            Text(
                              'Update Password',
                              textAlign: TextAlign.center,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fill in your details.',
                              textAlign: TextAlign.center,
                              style:
                              Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Full Name Input
                            // TextFormField(
                            //   controller: _nameController,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Full Name',
                            //     hintText: 'Enter your Name',
                            //     prefixIcon: Icon(Icons.person_rounded),
                            //   ),
                            // ),
                            // const SizedBox(height: 16),

                            // // ID Input
                            // TextFormField(
                            //   controller: _emailController,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Email',
                            //     hintText: 'Enter your Email',
                            //     prefixIcon: Icon(Icons.email),
                            //   ),
                            //   keyboardType: TextInputType.emailAddress,
                            // ),
                            const SizedBox(height: 16),   // ID Input

                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter your Number',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                            ),
                            const SizedBox(height: 16),

                            // // Password Input (no eye icon)
                            // TextFormField(
                            //   controller: _passwordController,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Old Password',
                            //     hintText: 'Create a password',
                            //     prefixIcon: Icon(Icons.lock_rounded),
                            //   ),
                            //   obscureText: false,
                            // ),
                            // const SizedBox(height: 16),

                            TextFormField(
                              controller: _newPasswordController,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                hintText: 'Enter password again',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded),
                                // suffixIcon: IconButton(
                                //   icon: Icon(
                                //     _obscureNewPassword
                                //         ? Icons.visibility_off_rounded
                                //         : Icons.visibility_rounded,
                                //   ),
                                //   onPressed: () {
                                //     setState(() {
                                //       _obscureNewPassword = !_obscureNewPassword;
                                //     });
                                //   },
                                // ),
                              ),
                              // obscureText: _obscureNewPassword,
                            ),

                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _rePasswordController,
                              decoration: InputDecoration(
                                labelText: 'Re-enter New Password',
                                hintText: 'Enter password again',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewRePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureNewRePassword = !_obscureNewRePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureNewRePassword,
                            ),
                            const SizedBox(height: 24),

                            // Register Button
                          ElevatedButton(
                            // onPressed: () {
                            //   String name = _nameController.text.trim();
                            //   String phone = _phoneController.text.trim();
                            //   String password = _passwordController.text.trim();
                            //   String rePassword = _rePasswordController.text.trim();
                            //   String email = _emailController.text.trim();
                            //
                            //   // Validation
                            //   if (name.isEmpty || phone.isEmpty || password.isEmpty || rePassword.isEmpty || email.isEmpty) {
                            //     Fluttertoast.showToast(
                            //       msg: "All fields are required",
                            //       backgroundColor: Colors.red,
                            //     );
                            //     return;
                            //   }
                            //   if (!_isValidEmail(email)) {
                            //     Fluttertoast.showToast(
                            //       msg: "Enter a valid email address",
                            //       backgroundColor: Colors.red,
                            //     );
                            //     return;
                            //   }
                            //   if (phone.length != 10) {
                            //     Fluttertoast.showToast(
                            //       msg: "Phone number must be 10 digits",
                            //       backgroundColor: Colors.red,
                            //     );
                            //     return;
                            //   }
                            //   if (password.length < 4) {
                            //     Fluttertoast.showToast(
                            //       msg: "Password must be at least 4 characters",
                            //       backgroundColor: Colors.red,
                            //     );
                            //     return;
                            //   }
                            //   if (password != rePassword) {
                            //     Fluttertoast.showToast(
                            //       msg: "Passwords do not match",
                            //       backgroundColor: Colors.red,
                            //     );
                            //     return;
                            //   }
                            //
                            //   // controller.register(
                            //   //   context: context,
                            //   //   name: name,
                            //   //   password: password,
                            //   //   mobile: phone,
                            //   //   email: email,
                            //   // );
                            // },
                            onPressed: () {
                                String mobile = _phoneController.text.trim();
                                String newPassword = _newPasswordController.text.trim();
                                String rePassword = _rePasswordController.text.trim();
                                  if (mobile.isEmpty  || newPassword.isEmpty || rePassword.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "All fields are required",
                                      backgroundColor: Colors.red,
                                    );
                                    return;
                                  }
                                if (newPassword.length < 4) {
                                  Fluttertoast.showToast(
                                    msg: "Password must be at least 4 characters",
                                    backgroundColor: Colors.red,
                                  );
                                  return;
                                }
                                if (newPassword != rePassword) {
                                  Fluttertoast.showToast(
                                    msg: "Passwords do not match",
                                    backgroundColor: Colors.red,
                                  );
                                  return;
                                }
                              controller.changePassword(
                                  context: context,
                                mobile: mobile,
                                newPassword: newPassword
                                );
                            },
                            child: const Text('Update Password'),
                          ),
                            const SizedBox(height: 24),
                            //
                            // // Already have an account?
                            // TextButton(
                            //   onPressed: () {
                            //     Navigator.pop(context);
                            //   },
                            //   child: Text(
                            //     "Already have an account? Login",
                            //     style: TextStyle(color: ColorConstants().teal),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
