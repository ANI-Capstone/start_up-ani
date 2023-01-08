import 'package:ani_capstone/utils.dart';

class UserData {
  String name, email, phone, street, barangay, city, province, typeName;

  String? id, photoUrl;
  int zipcode, userTypeId;

  UserData(
      {this.id,
      this.photoUrl,
      required this.name,
      required this.email,
      required this.phone,
      required this.street,
      required this.barangay,
      required this.city,
      required this.province,
      required this.zipcode,
      required this.userTypeId,
      required this.typeName});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'imageUrl': photoUrl,
        'userType': {'typeName': typeName, 'userTypeId': userTypeId},
        'address': {
          'barangay': barangay,
          'city': city,
          'street': street,
          'province': province,
          'zipcode': zipcode
        },
        'createdAt': Utils.fromDateTimeToJson(DateTime.now())
      };

  static UserData fromJson(Map<String, dynamic> json) => UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      street: json['address']['street'],
      barangay: json['address']['barangay'],
      city: json['address']['city'],
      province: json['address']['province'],
      zipcode: json['address']['zipcode'],
      userTypeId: json['userType']['userTypeId'],
      typeName: json['userType']['typeName']);
}
