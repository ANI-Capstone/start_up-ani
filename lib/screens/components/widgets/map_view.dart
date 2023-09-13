import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapView extends StatefulWidget {
  const MapView(
      {Key? key,
      required this.openMapView,
      required this.setPrecise,
      required this.controller,
      required this.pc,
      required this.isOpen,
      required this.location,
      required this.setIsOpen,
      required this.clearMarker,
      required this.googleMap,
      required this.centerMap})
      : super(key: key);

  final Function(bool open) openMapView;
  final Function(LatLng) setPrecise;
  final LatLng location;
  final Completer<GoogleMapController> controller;
  final PanelController pc;
  final bool isOpen;
  final VoidCallback clearMarker;
  final Function(bool) setIsOpen;
  final Widget googleMap;
  final Function(LatLng, int) centerMap;
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool isGettingLoc = false;

  @override
  void initState() {
    widget.centerMap(widget.location, 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            widget.googleMap,
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    widget.openMapView(false);
                  },
                  child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: primaryColor, blurRadius: 3)
                          ]),
                      child: const Icon(
                        Icons.arrow_back,
                        color: linkColor,
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      isGettingLoc = true;
                    });
                    final loc = await Geolocator.getCurrentPosition();
                    setState(() {
                      isGettingLoc = false;
                    });
                    widget.centerMap(LatLng(loc.latitude, loc.longitude), 1);
                  },
                  child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: primaryColor, blurRadius: 3)
                          ]),
                      child: const Icon(
                        Icons.my_location,
                        color: linkColor,
                      )),
                ),
              ),
            ),
            SlidingUpPanel(
              controller: widget.pc,
              minHeight: height * 0.08,
              maxHeight: height * 0.14,
              renderPanelSheet: false,
              isDraggable: false,
              defaultPanelState: PanelState.OPEN,
              panel: !widget.isOpen
                  ? Container(
                      height: height * 0.08,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: likeColor,
                              offset: Offset(0, 0),
                              blurRadius: 0.5)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                      ),
                      child: const SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.locationDot,
                              size: 16,
                              color: linkColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Pin your exact location.',
                              style: TextStyle(color: linkColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      height: height * 0.14,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: primaryColor, blurRadius: 0.5)
                        ],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Confirm your location?',
                              style: TextStyle(color: linkColor, fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      widget.setPrecise(widget.location);
                                      ShoWInfo.showToast(
                                          'Location has been set successfully.',
                                          3);

                                      widget.openMapView(false);
                                      widget.centerMap(widget.location, 0);
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: linkColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (() {
                                      widget.setIsOpen(false);
                                      widget.clearMarker();
                                      widget.pc.close();
                                    }),
                                    child: Container(
                                      width: 150,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: linkColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: const Text(
                                        'Remove',
                                        style: TextStyle(
                                            color: linkColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
            ),
            if (isGettingLoc)
              Container(
                height: height,
                width: double.infinity,
                color: Colors.white.withOpacity(0.8),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Getting location...',
                          style: TextStyle(color: linkColor, fontSize: 14),
                        ),
                      )
                    ]),
              ),
          ],
        ),
      ),
    );
  }
}
