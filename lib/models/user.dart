import 'package:meta/meta.dart';

import '../utils.dart';

class UserField {
  static final String lastMessageTime = 'lastMessageTime';
}

class User {
  String? userId;
  String name;
  String photoUrl;
  // DateTime lastMessageTime;

  User({this.userId, required this.name, required this.photoUrl
      // required this.lastMessageTime,
      });

  User copyWith({
    String? userId,
    String? name,
    String? photoUrl,
    // DateTime? lastMessageTime,
  }) =>
      User(userId: userId, name: name!, photoUrl: photoUrl!
          // lastMessageTime: lastMessageTime!,
          );

  static User fromJson(Map<String, dynamic> json) => User(
        userId: json['id'],
        name: json['name'],
        photoUrl: json['imageUrl'],
        // lastMessageTime: Utils.toDateTime(json['lastMessageTime']),
      );

  Map<String, dynamic> toJson() => {
        'id': userId,
        'name': name,
        'imageUrl': photoUrl,
        // 'lastMessageTime': Utils.fromDateTimeToJson(lastMessageTime),
      };
}
