import 'package:flutter/material.dart';

class MessagePlaceholder extends StatelessWidget {
  MessagePlaceholder({
    this.title: 'Nothing Here',
    this.message: 'Add a new item to get started.',
  });
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.sentiment_dissatisfied,
            size: 100.0,
//              color: iconColor,
          ),
          SizedBox(
            height: 20.0,
          ),
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.w700,
//                  color: textColor
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                message,
                style: TextStyle(
                  fontSize: 15.0, fontWeight: FontWeight.normal,
//                  color: textColor
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}