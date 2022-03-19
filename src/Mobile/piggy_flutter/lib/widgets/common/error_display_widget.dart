import 'package:flutter/material.dart';
import 'package:piggy_flutter/widgets/common/message_placeholder.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final bool? visible;

  const ErrorDisplayWidget({Key? key, this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible! ? 1.0 : 0.0,
      child: MessagePlaceholder(
        title: 'Something went wrong',
        message: 'An error occured during the operation, please try again.',
        icon: Icons.error_outline,
      ),
    );
  }
}
