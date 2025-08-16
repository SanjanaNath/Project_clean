import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_clean/utils/color_constants.dart';
import 'package:project_clean/widgets/backgroundCircles.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../services/local_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundCircles(
        child: Consumer<AuthController>(builder: (context, controller, child) {
          return ModalProgressHUD(
            inAsyncCall: controller.isLoading,
            blur: 2,
            progressIndicator: CircularProgressIndicator(
              color: ColorConstants().teal,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 100,
                          color: ColorConstants().teal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF333333),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your survey.',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFF666666),
                                  ),
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _idController,
                          decoration: const InputDecoration(
                            labelText: 'ID',
                            hintText: 'Enter your ID',
                            prefixIcon: Icon(Icons.perm_identity_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your ID';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock_rounded),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.trim().length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Remove all previous routes
                              // Navigator.pushNamedAndRemoveUntil(
                              //   context,
                              //   '/check-in',
                              //       (route) => false,
                              // );
                              controller.login(
                                context: context,
                                password: _passwordController.text,
                                email: _idController.text,
                              );
                            }
                          },
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 24),
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.pushNamed(context, '/register');
                        //   },
                        //   child: Text(
                        //     "Don't have an account? Register",
                        //     style: TextStyle(color: ColorConstants().teal),
                        //   ),
                        // ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "Change Password",
                            style: TextStyle(color: ColorConstants().teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
