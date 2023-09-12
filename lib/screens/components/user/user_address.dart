import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/screens/components/widgets/address_field.dart';
import 'package:ani_capstone/screens/components/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  int fetchState = 0;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
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

    Geolocator.getCurrentPosition().then((loc) {
      setPrecise(LatLng(loc.latitude, loc.longitude));
    });
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
                    ),
                    MapView(openMapView: (open) {
                      openMapView(open);
                    }),
                  ],
                )),
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
}
