import 'package:ani_capstone/screens/components/widgets/address_field.dart';
import 'package:ani_capstone/screens/components/widgets/map_view.dart';
import 'package:flutter/material.dart';

class UserAddress extends StatefulWidget {
  const UserAddress({Key? key}) : super(key: key);

  @override
  _UserAddressState createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  int index = 0;

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
    return SafeArea(
        child: IndexedStack(
      index: index,
      children: [
        AddressField(
          openMapView: (open) {
            openMapView(open);
          },
        ),
        MapView(openMapView: (open) {
          openMapView(open);
        }),
      ],
    ));
  }
}
