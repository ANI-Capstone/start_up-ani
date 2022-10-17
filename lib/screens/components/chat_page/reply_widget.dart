import 'dart:io';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  final Message message;
  final VoidCallback? onCancelReply;

  const ReplyMessageWidget({
    required this.message,
    this.onCancelReply,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          children: [
            Container(
              color: primaryColor,
              width: 4,
            ),
            const SizedBox(width: 8),
            Expanded(child: buildReplyMessage()),
          ],
        ),
      );

  Widget buildReplyMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  message.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  onTap: onCancelReply,
                  child: const Icon(Icons.close, size: 16),
                )
            ],
          ),
          const SizedBox(height: 8),
          message.typeId == 1
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: message.message.contains('https://')
                      ? Image.network(
                          message.message,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.file(File(message.message),
                          width: 120, height: 120, fit: BoxFit.cover))
              : Text(message.message,
                  style: const TextStyle(color: Colors.black54)),
        ],
      );
}
