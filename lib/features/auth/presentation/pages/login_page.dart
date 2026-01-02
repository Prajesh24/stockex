import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/utils/snackbar_utils.dart';
import 'package:stockex/features/auth/presentation/state/auth_state.dart';
import 'package:stockex/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:stockex/screen/button_navigator_screen.dart';
import 'package:stockex/features/auth/presentation/pages/singup_page.dart';
import 'package:stockex/core/widgets/my_text_field.dart';
import '../../../../core/widgets/my_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  /// Handle Login Button
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );
    }
  }

  /// Navigate to Register
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Login failed');
      }

      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login successful');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ButtonNavigatorScreen()),
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
                    "Welcome to Stockex",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login to continue",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  MyTextField(
                    label: "Email",
                    controller: emailController,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter email" : null,
                  ),

                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Password",
                    controller: passController,
                    obscure: true,
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter password"
                        : null,
                  ),

                  const SizedBox(height: 30),

                  MyButton(text: "Login", onPressed: _handleLogin),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
