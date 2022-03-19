import 'package:flutter/material.dart';
import 'package:piggy_flutter/models/api_response.dart';
import 'package:piggy_flutter/utils/uidata.dart';

showError(BuildContext context, ApiResponse snapshot) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(UIData.error),
      content: Text(snapshot.error!),
      actions: <Widget>[
        TextButton(
          child: Text(UIData.ok),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );
}

showSuccess({required BuildContext context, String? message, IconData? icon}) {
  showDialog(
    context: context,
    builder: (context) => Center(
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.black,
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.green,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                message!,
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    ),
  )
      .timeout(Duration(seconds: 2))
      .catchError((_) => Navigator.pop(context))
      .then((_) {
    Navigator.pop(context);
  });
}

showProgress(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.yellow,
            ),
          ));
}

hideProgress(BuildContext context) {
  Navigator.pop(context);
}
