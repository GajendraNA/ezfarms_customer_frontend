import 'package:customer/util/my_button.dart';
import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String text; // Text to be displayed in the dialog

  const DialogBox({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text, // Display the text passed as a parameter
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(text: "Yes I confirm", onPressed: onSave, buttonColor: Colors.red),
                MyButton(text: "Cancel", onPressed: onCancel, buttonColor: Colors.greenAccent),
              ],
            )
          ],
        ),
      ),
    );
  }
}
