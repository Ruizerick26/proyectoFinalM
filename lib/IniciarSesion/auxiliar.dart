import 'package:flutter/material.dart';

void mostrarSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(milliseconds: 1200),
  ));
}
