import 'dart:async';
import 'dart:convert';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/address.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocateAddress extends StatefulWidget {
  const UserLocateAddress(
      {Key? key, this.isNew = false, required this.saveAddress})
      : super(key: key);

  final bool? isNew;
  final Function(Address address) saveAddress;
  @override
  _UserLocateAddressState createState() => _UserLocateAddressState();
}

class _UserLocateAddressState extends State<UserLocateAddress> {
  final _region = TextEditingController();
  final _province = TextEditingController();
  final _city = TextEditingController();
  final _barangay = TextEditingController();
  final _postal = TextEditingController();
  final _street = TextEditingController();

  final List<FocusNode> screenFocus = List.generate(4, (i) => FocusNode());

  LatLng? precise;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  final Set<Marker> _markers = {};

  List<Map> regions = [];
  Map? selectedRegion;
  String? selectedProvince;
  String? selectedCity;
  String? selectedBarangay;
  dynamic places;

  List<String> provinces = [];
  List<String> cities = [];
  List<String> barangays = [];

  @override
  void initState() {
    super.initState();

    getPlaces();
  }

  Future<void> getPlaces() async {
    final String res1 =
        await rootBundle.loadString('assets/tags/ph_regions.json');
    final data = await json.decode(res1) as List;

    regions = List.from(data);

    final res2 = await rootBundle.loadString('assets/tags/ph_places.json');
    places = await json.decode(res2);

    final loc = await Geolocator.getCurrentPosition();

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(loc.latitude, loc.longitude),
            tilt: 0,
            zoom: 18)));

    _markers.clear();
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(loc.toString()),
          position: LatLng(loc.latitude, loc.longitude),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  Future<List<String>> getProvinces() async {
    if (selectedRegion != null) {
      final province = places[selectedRegion!['key']]['province_list'];

      return List.from(province.keys);
    }

    return [];
  }

  Future<List<String>> getCities() async {
    if (selectedRegion != null && selectedProvince != null) {
      final cities = places[selectedRegion!['key']]['province_list']
          [selectedProvince!.toUpperCase()]['municipality_list'];

      return List.from(cities.keys);
    }

    return [];
  }

  Future<List<String>> getBarangays() async {
    if (selectedRegion != null &&
        selectedProvince != null &&
        selectedCity != null) {
      final barangays = places[selectedRegion!['key']]['province_list']
              [selectedProvince!.toUpperCase()]['municipality_list']
          [selectedCity!.toUpperCase()]['barangay_list'];

      return List.from(barangays);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: const Icon(
          FontAwesomeIcons.xmark,
          color: linkColor,
          size: 20,
        ),
        title: Text(widget.isNew! ? 'NEW ADDRESS' : 'USER ADDRESS',
            style:
                const TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding - 15, vertical: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Complete Address',
              style: TextStyle(color: linkColor, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TypeAheadField(
                        minCharsForSuggestions: 0,
                        hideSuggestionsOnKeyboardHide: true,
                        suggestionsBoxVerticalOffset: 15,
                        textFieldConfiguration: TextFieldConfiguration(
                          focusNode: screenFocus[0],
                          controller: _region,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: linkColor),
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              isCollapsed: true,
                              // errorText: 'Invalid',
                              alignLabelWithHint: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 13, 10, 13),
                              hintText: 'Region',
                              hintStyle:
                                  TextStyle(fontSize: 15, color: primaryColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5)),
                                  borderSide: BorderSide.none),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white),
                          onChanged: (v) {
                            setState(() {});
                          },
                        ),
                        suggestionsCallback: (pattern) async {
                          List<Map> matches = [];
                          matches.addAll(regions);

                          matches.retainWhere((s) {
                            return s['name']
                                .toLowerCase()
                                .contains(pattern.toLowerCase());
                          });

                          return matches;
                        },
                        noItemsFoundBuilder: (context) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              'No items found!',
                              style: TextStyle(color: linkColor, fontSize: 15),
                            ),
                          );
                        },
                        itemBuilder: (context, suggestion) {
                          final sg = suggestion as Map;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              sg['name'].toString(),
                              style: const TextStyle(
                                  color: primaryColor, fontSize: 15),
                            ),
                          );
                        },
                        itemSeparatorBuilder: (context, i) => const Divider(),
                        onSuggestionSelected: (suggestion) {
                          final sg = suggestion as Map;
                          setState(() {
                            _region.text = sg['name'];
                            selectedRegion = sg;
                          });
                        },
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5))),
                      height: 44,
                      width: 40,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: linkColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            _buildTextFieldD(
                label: 'Province',
                controller: _province,
                suggestions: getProvinces(),
                focus: screenFocus[1],
                onTap: () {
                  screenFocus[1].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    _province.text = suggestion.toString();
                    selectedProvince = suggestion!.toString();
                  });
                }),
            _buildTextFieldD(
                label: 'City/Municipality',
                controller: _city,
                suggestions: getCities(),
                focus: screenFocus[2],
                onTap: () {
                  screenFocus[2].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    _city.text = suggestion.toString();
                    selectedCity = suggestion.toString();
                  });
                }),
            _buildTextFieldD(
                label: 'Barangay',
                controller: _barangay,
                suggestions: getBarangays(),
                focus: screenFocus[3],
                onTap: () {
                  screenFocus[3].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    _barangay.text = suggestion.toString();
                    selectedBarangay = suggestion.toString();
                  });
                }),
            _cTextField(controller: _postal, hint: 'Postal Code'),
            _cTextField(
                controller: _street, hint: 'Street, Building, House No.'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: 'Precise Location',
                        style: TextStyle(
                          color: linkColor,
                          fontSize: 15,
                        )),
                    WidgetSpan(
                      child: SizedBox(width: 5),
                    ),
                    TextSpan(
                        text: '(Tap to open map view)',
                        style: TextStyle(
                          color: linkColor,
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
            ),
            DottedBorder(
              color: linkColor.withOpacity(0.7),
              borderType: BorderType.RRect,
              radius: const Radius.circular(5),
              dashPattern: const [3, 2],
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      mapType: MapType.terrain,
                      initialCameraPosition: _kGooglePlex,
                      markers: _markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: GestureDetector(
                onTap: () {
                  // final address = Address(
                  //     region: _region.text.trim(),
                  //     province: province,
                  //     city: city,
                  //     barangay: barangay,
                  //     postal: postal,
                  //     precise: precise);
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: linkColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                      child: Text(
                    'Save Address',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildTextFieldD(
      {required String label,
      required TextEditingController controller,
      required Future<List<String>> suggestions,
      required FocusNode focus,
      required VoidCallback onTap,
      required Function(Object?) onSelected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TypeAheadField(
                minCharsForSuggestions: 0,
                hideSuggestionsOnKeyboardHide: true,
                suggestionsBoxVerticalOffset: 15,
                textFieldConfiguration: TextFieldConfiguration(
                  focusNode: focus,
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                      fontSize: 14, fontFamily: 'Roboto', color: linkColor),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      isCollapsed: true,
                      // errorText: 'Invalid',
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
                      hintText: label,
                      hintStyle:
                          const TextStyle(fontSize: 15, color: primaryColor),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5)),
                          borderSide: BorderSide.none),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white),
                  onChanged: (v) {
                    setState(() {});
                  },
                ),
                suggestionsCallback: (pattern) async {
                  final sg = await suggestions;
                  List<String> matches = <String>[];
                  matches.addAll(sg);

                  matches.retainWhere((s) {
                    return s.toLowerCase().contains(pattern.toLowerCase());
                  });

                  return matches
                      .map((e) => e
                          .split(' ')
                          .map((word) => word.capitalize())
                          .join(' '))
                      .toList();
                },
                noItemsFoundBuilder: (context) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      'No items found!',
                      style: TextStyle(color: linkColor, fontSize: 15),
                    ),
                  );
                },
                itemBuilder: (context, suggestion) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      suggestion.toString(),
                      style: const TextStyle(color: primaryColor, fontSize: 15),
                    ),
                  );
                },
                itemSeparatorBuilder: (context, i) => const Divider(),
                onSuggestionSelected: (suggestion) {
                  onSelected(suggestion);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5))),
              height: 44,
              width: 40,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: linkColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cTextField(
      {String? hint,
      String? suffix,
      required TextEditingController controller,
      TextInputType? type = TextInputType.text,
      String? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        style: const TextStyle(
            fontSize: 14, fontFamily: 'Roboto', color: linkColor),
        keyboardType: type,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: primaryColor),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 14, color: primaryColor)),
      ),
    );
  }
}
