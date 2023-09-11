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

class AddressField extends StatefulWidget {
  const AddressField(
      {Key? key,
      this.isNew = true,
      required this.openMapView,
      required this.setAddress,
      required this.precise,
      required this.setPrecise})
      : super(key: key);

  final bool? isNew;
  final LatLng precise;
  final Function(bool open) openMapView;
  final Function(Address address) setAddress;
  final Function(LatLng precise) setPrecise;
  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  final List<FocusNode> screenFocus = List.generate(4, (i) => FocusNode());

  List<TextEditingController> textController =
      List.generate(6, (i) => TextEditingController());
  List<bool> errors = List.generate(5, (i) => false);

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

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(bearing: 0, target: widget.precise, tilt: 0, zoom: 18)));

    _markers.clear();
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(widget.precise.toString()),
          position: LatLng(widget.precise.latitude, widget.precise.longitude),
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
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            FontAwesomeIcons.xmark,
            color: linkColor,
            size: 20,
          ),
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
                        controller: textController[0],
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: linkColor),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            isCollapsed: true,
                            errorText:
                                errors[0] ? "Region field is required." : null,
                            alignLabelWithHint: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 13, 10, 13),
                            hintText: 'Region',
                            hintStyle: const TextStyle(
                                fontSize: 15, color: primaryColor),
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5)),
                                borderSide: BorderSide.none),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white),
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
                          textController[0].text = sg['name'];
                          selectedRegion = sg;
                          errors[0] = false;
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
            _buildTextFieldD(
                label: 'Province',
                controller: textController[1],
                suggestions: getProvinces(),
                focus: screenFocus[1],
                onTap: () {
                  screenFocus[1].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    textController[1].text = suggestion.toString();
                    selectedProvince = suggestion!.toString();
                    errors[1] = false;
                  });
                },
                error: errors[1] ? "Province is required." : null),
            _buildTextFieldD(
                label: 'City/Municipality',
                controller: textController[2],
                suggestions: getCities(),
                focus: screenFocus[2],
                onTap: () {
                  screenFocus[2].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    textController[2].text = suggestion.toString();
                    selectedCity = suggestion.toString();
                    errors[2] = false;
                  });
                },
                error: errors[2] ? "City/Municipality is required." : null),
            _buildTextFieldD(
                label: 'Barangay',
                controller: textController[3],
                suggestions: getBarangays(),
                focus: screenFocus[3],
                onTap: () {
                  screenFocus[3].requestFocus();
                },
                onSelected: (suggestion) {
                  setState(() {
                    textController[3].text = suggestion.toString();
                    selectedBarangay = suggestion.toString();
                    errors[3] = false;
                  });
                },
                error: errors[3] ? "Barangay is required." : null),
            _cTextField(
              controller: textController[4],
              hint: 'Postal Code',
              validator: errors[4] ? "Postal code is required." : null,
              onChanged: (v) {
                setState(() {
                  textController[4].text = v;
                  errors[4] = false;
                });
              },
            ),
            _cTextField(
                controller: textController[5],
                hint: 'Street, Building, House No.',
                onChanged: (v) {
                  setState(() {
                    textController[5].text = v;
                  });
                }),
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
                    onTap: (_) {
                      widget.openMapView(true);
                    },
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
                  bool isError = false;
                  for (int i = 0; i < 5; i++) {
                    setState(() {
                      if (textController[i].text.isEmpty) {
                        errors[i] = true;
                        isError = true;
                      } else {
                        errors[i] = false;
                      }
                    });
                  }

                  if (isError) return;

                  final address = Address(
                      region: textController[0].text.trim(),
                      province: textController[1].text.trim(),
                      city: textController[2].text.trim(),
                      barangay: textController[3].text.trim(),
                      postal: int.parse(textController[4].text.trim()),
                      street: textController[5].text.trim(),
                      precise: widget.precise);

                  address.toCompleteAddress();

                  print(address.completeAddress);
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
      required Function(Object?) onSelected,
      required String? error}) {
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
                      errorText: error,
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
      String? validator,
      Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        style: const TextStyle(
            fontSize: 14, fontFamily: 'Roboto', color: linkColor),
        keyboardType: type,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
            hintText: hint,
            errorText: validator,
            hintStyle: const TextStyle(fontSize: 14, color: primaryColor),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 14, color: primaryColor)),
        onChanged: onChanged,
      ),
    );
  }
}
