import 'dart:io';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCallAlertDialog(
  BuildContext context,
  String? title,
  String? content,
  Future<void> Function() onTap,
  Color? yesColor,
) {
  if (Platform.isIOS) {
    // iOS Alert
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(content!),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onTap();
              // delete logic
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  } else {
    // Android Alert
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title!),
        content: Text(content!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onTap();
              // delete logic
            },
            child: Text("Yes", style: TextStyle(color: yesColor!)),
          ),
        ],
      ),
    );
  }
}
