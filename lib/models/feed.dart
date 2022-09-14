import 'package:ani_capstone/models/user.dart';

class Feed {
  User author;
  String caption;
  String price;
  String upload;
  String date;

  Feed(
      {required this.author,
      required this.caption,
      required this.price,
      required this.upload,
      required this.date});
}
