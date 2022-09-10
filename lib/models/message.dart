import 'package:ani_capstone/models/user.dart';

class Message {
  User author;
  String message;
  String timeStamp;

  Message(
      {required this.author, required this.message, required this.timeStamp});
}
