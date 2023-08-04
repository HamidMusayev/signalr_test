import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ChatBubble.left(
      {Key? key,
      required this.message,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.textColor = Colors.black87,
      this.backgroundColor = const Color(0xFFEEEEEE),
      this.borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(0),
      )})
      : super(key: key);

  const ChatBubble.right(
      {Key? key,
      required this.message,
      this.mainAxisAlignment = MainAxisAlignment.end,
      this.crossAxisAlignment = CrossAxisAlignment.end,
      this.textColor = Colors.white,
      this.backgroundColor = Colors.lightBlue,
      this.borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(12),
      )})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Text(
                    message['message'],
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    message['user'],
                    style: TextStyle(color: textColor.withOpacity(.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
