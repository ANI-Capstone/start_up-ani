import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserMap extends StatefulWidget {
  const UserMap({Key? key}) : super(key: key);

  @override
  _UserMapState createState() => _UserMapState();
}

class _UserMapState extends State<UserMap> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late bool serviceEnabled;
  late LocationPermission permission;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    // getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final loc = await Geolocator.getCurrentPosition();

    // List<Placemark> placemarks =
    //     await placemarkFromCoordinates(loc.latitude, loc.longitude);

    // print(placemarks);

    // final GoogleMapController controller = await _controller.future;
    // await controller.animateCamera(CameraUpdate.newCameraPosition(
    //     CameraPosition(
    //         bearing: 0,
    //         target: LatLng(loc.latitude, loc.longitude),
    //         tilt: 0,
    //         zoom: 18)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //     automaticallyImplyLeading: false,
        //     title: const Text('FARMERS MAP',
        //         style: TextStyle(
        //           color: linkColor,
        //           fontWeight: FontWeight.bold,
        //           fontFamily: 'Roboto',
        //         )),
        //     backgroundColor: Colors.transparent,
        //     foregroundColor: Colors.transparent,
        //     elevation: 0),
        body: GoogleMap(
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          mapType: MapType.terrain,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
