import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? buttonColor; // New property for custom button color

  const MyButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonColor, // Initialize the buttonColor property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: buttonColor ?? Theme.of(context).dividerColor, // Use custom color or default to theme color
      child: Text(text),
    );
  }
}
