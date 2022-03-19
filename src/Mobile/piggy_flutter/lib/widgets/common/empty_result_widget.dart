import 'package:flutter/material.dart';
import 'package:piggy_flutter/widgets/common/message_placeholder.dart';

class EmptyResultWidget extends StatelessWidget {
  final bool? visible;

  const EmptyResultWidget({Key? key, this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible! ? 1.0 : 0.0,
      child: MessagePlaceholder(),
    );
  }
}
