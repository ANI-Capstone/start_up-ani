import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/screens/components/widgets/address_field.dart';
import 'package:ani_capstone/screens/components/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class UserAddress extends StatefulWidget {
  const UserAddress({Key? key, required this.setAddress}) : super(key: key);

  final Function(Address address) setAddress;
  @override
  _UserAddressState createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  int index = 0;
  LatLng? precise;

  late bool serviceEnabled;
  late LocationPermission permission;

  final List<Completer<GoogleMapController>> _controller = [
    Completer(),
    Completer()
  ];
  static const LatLng _center = LatLng(45.343434, -122.545454);
  final Set<Marker> _markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  LatLng? location;
  final PanelController _pc = PanelController();
  bool isOpen = false;

  int fetchState = 0;

  @override
  void initState() {
    getCurrentLocation();
    addCustomIcon();
    super.initState();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(20, 20)),
            "assets/icons/pin.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  void clearMarker() {
    setState(() {
      _markers.clear();
    });
  }

  void setIsOpen(bool open) {
    setState(() {
      isOpen = open;
    });
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
        if (mounted) {
          setState(() {
            fetchState = -1;
          });
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          fetchState = -1;
        });
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final loc = await Geolocator.getCurrentPosition();

    location = LatLng(loc.latitude, loc.longitude);
    centerMap(location!, 0);
    setPrecise(location!);
  }

  void centerMap(LatLng loc, int i) async {
    final GoogleMapController controller = await _controller[i].future;

    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            bearing: 0,
            target: LatLng(loc.latitude, loc.longitude),
            tilt: 0,
            zoom: 18)));

    _handleTap(loc, i);
  }

  void setPrecise(LatLng loc) async {
    setState(() {
      precise = loc;
      fetchState = 1;
    });
  }

  void openMapView(bool open) {
    setState(() {
      if (open) {
        index = 1;
      } else {
        index = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      body: SafeArea(
          child: fetchState != 1
              ? statusBuilder()
              : IndexedStack(
                  index: index,
                  children: [
                    AddressField(
                      setAddress: (address) {
                        widget.setAddress(address);
                      },
                      openMapView: (open) {
                        openMapView(open);
                      },
                      precise: precise!,
                      setPrecise: (precise) {
                        setPrecise(precise);
                      },
                      googleMap: googleMap(),
                    ),
                    MapView(
                      openMapView: (open) {
                        openMapView(open);
                      },
                      setPrecise: (loc) {
                        setPrecise(loc);
                      },
                      location: location!,
                      setIsOpen: (open) {
                        setIsOpen(open);
                      },
                      clearMarker: () {
                        clearMarker();
                      },
                      pc: _pc,
                      isOpen: isOpen,
                      controller: _controller[1],
                      googleMap: googleMap(),
                      centerMap: (loc, i) {
                        centerMap(loc, i);
                      },
                    ),
                  ],
                )),
    );
  }

  Widget googleMap() {
    return GoogleMap(
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(target: _center, zoom: 11.0),
      markers: _markers,
      mapType: MapType.normal,
      onTap: (loc) {
        if (index == 0) {
          openMapView(true);
        } else {
          _handleTap(loc, index);
        }
      },
    );
  }

  Widget statusBuilder() {
    if (fetchState == -1) {
      return const Center(child: Text('An error occurred, please try again.'));
    } else {
      return const SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Loading, please wait...',
                  style: TextStyle(color: linkColor, fontSize: 14),
                ),
              )
            ],
          ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_controller[index].isCompleted) {
      _controller[1].complete(controller);
      return;
    }
    _controller[index].complete(controller);
  }

  _handleTap(LatLng point, int i) async {
    _markers.clear();
    final marker = Marker(
      markerId: MarkerId(point.toString()),
      position: point,
      infoWindow: const InfoWindow(title: "You are here."),
      icon: markerIcon,
    );

    setState(() {
      location = point;

      _markers.add(marker);

      isOpen = true;
    });

    if (_pc.isAttached) {
      _pc.open();
    }

    final GoogleMapController controller = await _controller[i].future;
    await Future.delayed(const Duration(milliseconds: 500));
    controller.showMarkerInfoWindow(marker.markerId);
  }
}
