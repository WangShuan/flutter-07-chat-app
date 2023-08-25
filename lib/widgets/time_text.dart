import 'package:flutter/material.dart';

class TimeText extends StatelessWidget {
  const TimeText(this.sendTime, {super.key});
  final DateTime sendTime;
  @override
  Widget build(BuildContext context) {
    return Text(
      sendTime.toString().split('.')[0],
      style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSecondaryContainer),
    );
  }
}
