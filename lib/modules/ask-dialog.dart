import 'package:flutter/material.dart';

class AskDialog {
  final String title;
  final String message;
  final String buttonYES;
  final String buttonNO;
  final Function yesFunc;
  final Function? noFunc;
  final bool dissable;

  AskDialog({
    required this.title,
    required this.message,
    this.buttonYES = 'Yes',
    this.buttonNO = 'No',
    required this.yesFunc,
    this.noFunc,
    this.dissable = true,
  });

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog(
      barrierDismissible: dissable,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(buttonYES),
              onPressed: () {
                yesFunc();
                // Navigator.of(context).pop();
              },
            ),
            if (noFunc != null)
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(buttonNO),
                onPressed: () {
                  noFunc!();
                  // Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }
}

class PolicyDialog {
  final String title;
  final Widget message;
  final Function yesFunc;

  PolicyDialog({
    required this.title,
    required this.message,
    required this.yesFunc,
  });

  Future<void> dialogBuilder(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: message,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text('Agree'),
              onPressed: () {
                yesFunc();
              },
            ),
          ],
        );
      },
    );
  }
}
