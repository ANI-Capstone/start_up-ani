
class User {
  String? userId;
  String name;
  String photoUrl;
  String? fcmToken;
  // DateTime lastMessageTime;

  User({this.userId, required this.name, required this.photoUrl, this.fcmToken
      // required this.lastMessageTime,
      });

  // User copyWith({
  //   String? userId,
  //   String? name,
  //   String? photoUrl,
  //   String? fcmToken,
  //   // DateTime? lastMessageTime,
  // }) =>
  //     User(userId: userId, name: name!, photoUrl: photoUrl!, fcmToken: fcmToken!
  //         // lastMessageTime: lastMessageTime!,
  //         );

  static User fromJson(Map<String, dynamic> json) => User(
      userId: json['id'],
      name: json['name'],
      photoUrl: json['imageUrl'],
      fcmToken: json['fcmToken']
      // lastMessageTime: Utils.toDateTime(json['lastMessageTime']),
      );

  Map<String, dynamic> toJson() => {
        'id': userId,
        'name': name,
        'imageUrl': photoUrl,
        'fcmToken': fcmToken
        // 'lastMessageTime': Utils.fromDateTimeToJson(lastMessageTime),
      };
}
