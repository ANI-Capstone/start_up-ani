import '../utils.dart';

class Message {
  String userId;
  String urlAvatar;
  String username;
  String message;
  DateTime createdAt;
  Message? replyMessage;
  String? type;
  bool seen;
  int? typeId;
  int? status;
  int? index;

  Message(
      {required this.userId,
      required this.urlAvatar,
      required this.username,
      required this.message,
      required this.createdAt,
      this.type,
      required this.seen,
      this.replyMessage,
      this.typeId,
      this.status,
      this.index});

  static Message fromJson(Map<String, dynamic> json) => Message(
      userId: json['idUser'],
      urlAvatar: json['urlAvatar'],
      username: json['username'],
      message: json['message'],
      createdAt: Utils.toDateTime(json['createdAt']),
      replyMessage: json['replyMessage'] == null
          ? null
          : Message.fromJson(json['replyMessage']),
      type: json['type'],
      typeId: json['typeId'],
      seen: json['seen'],
      status: json['status']);

  Map<String, dynamic> toJson() => {
        'idUser': userId,
        'urlAvatar': urlAvatar,
        'username': username,
        'message': message,
        'createdAt': Utils.fromDateTimeToJson(createdAt),
        'replyMessage': replyMessage != null ? replyMessage!.toJson() : null,
        'type': type,
        'typeId': typeId,
        'seen': seen,
        'status': status ?? 0
      };
}
