import 'package:flutter/material.dart';

/// A yes/cancel confirmation dialog. Sizes itself to its text, so long
/// messages and large system font sizes don't overflow.
class DialogBox extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String text;
  final String confirmLabel;

  const DialogBox({
    super.key,
    required this.onSave,
    required this.onCancel,
    required this.text,
    this.confirmLabel = 'Yes, I confirm',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        text,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: onSave,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Shows a [DialogBox] and returns true if the user confirmed.
Future<bool> confirm(BuildContext context, String text,
    {String confirmLabel = 'Yes, I confirm'}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => DialogBox(
      text: text,
      confirmLabel: confirmLabel,
      onSave: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.redAccent : Colors.green[700],
      behavior: SnackBarBehavior.floating,
    ));
}
