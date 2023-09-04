import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  String? completeAddress;
  final String region;
  final String province;
  final String city;
  final String barangay;
  final int postal;
  final String? street;

  final LatLng precise;

  Address(
      {this.completeAddress = '',
      required this.region,
      required this.province,
      required this.city,
      required this.barangay,
      required this.postal,
      this.street = '',
      required this.precise});

  static Address fromJson(Map<String, dynamic> json) => Address(
      completeAddress: json['completeAddress'],
      region: json['region'],
      province: json['province'],
      city: json['city'],
      barangay: json['barangay'],
      postal: json['postal'],
      street: json['street'],
      precise: LatLng.fromJson(json['precise'])!);

  void toCompleteAddress() {
    if (street!.isNotEmpty) {
      completeAddress = '${street!}, ';
    }

    completeAddress =
        '${completeAddress!}$barangay, $city, $province, $region, $postal';
  }

  Map<String, dynamic> toJson() => {
        'completeAddress': completeAddress,
        'region': region,
        'province': province,
        'city': city,
        'barangay': barangay,
        'postal': postal,
        'street': street,
        'precise': precise.toJson()
      };
}
