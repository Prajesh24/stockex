import 'package:flutter/material.dart';
import 'package:stockex/screen/login_screen.dart';
import 'package:stockex/widgets/my_text_field.dart';

import '../widgets/my_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    validator: (value) => value!.isEmpty ? "Enter name" : null,
                  ),

                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Email",
                    controller: emailController,
                    validator: (value) => value!.isEmpty ? "Enter email" : null,
                  ),

                  const SizedBox(height: 20),

                  MyTextField(
                    label: "Password",
                    controller: passController,
                    obscure: true,
                    validator: (value) =>
                        value!.length < 6 ? "Minimum 6 characters" : null,
                  ),

                  const SizedBox(height: 30),

                  MyButton(
                    text: "Register",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          });
                        },
                        child: const Text(
                          "Login",
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
