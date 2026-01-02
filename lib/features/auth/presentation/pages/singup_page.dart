import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/utils/snackbar_utils.dart';
import 'package:stockex/features/auth/presentation/pages/login_page.dart';
import 'package:stockex/core/widgets/my_text_field.dart';
import 'package:stockex/features/auth/presentation/state/auth_state.dart';
import 'package:stockex/features/auth/presentation/view_model/auth_view_model.dart';
import '../../../../core/widgets/my_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  /// Handle Register Button
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authViewModelProvider.notifier)
          .register(
            fullName: nameController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
            password: passController.text,
          );
    }
  }

  /// Navigate to Login
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration failed',
        );
      }

      if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Registration successful!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Register to get started",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  MyTextField(
                    label: "Full Name",
                    controller: nameController,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Email",
                    controller: emailController,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Phone Number",
                    controller: phoneController,
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter phone number"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Password",
                    controller: passController,
                    obscure: true,
                    validator: (value) => value != null && value.length < 6
                        ? "Minimum 6 characters"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Confirm Password",
                    controller: confirmPassController,
                    obscure: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm your password";
                      }
                      if (value != passController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  MyButton(text: "Register", onPressed: _handleRegister),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),

                  // Optional loading / error handling
                  // if (authState.isLoading) ...[
                  //   const SizedBox(height: 20),
                  //   const Center(child: CircularProgressIndicator()),
                  // ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
