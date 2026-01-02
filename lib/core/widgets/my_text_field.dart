import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
