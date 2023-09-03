import 'dart:async';
import 'dart:convert';

import 'package:ani_capstone/api/product_order_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/models/estab_order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/product_order.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/screens/components/user/user_locate_address.dart';
import 'package:ani_capstone/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class UserCreateOrder extends StatefulWidget {
  const UserCreateOrder({Key? key, required this.user, required this.products})
      : super(key: key);

  final UserData user;
  final List<Product> products;

  @override
  _UserCreateOrderState createState() => _UserCreateOrderState();
}

class _UserCreateOrderState extends State<UserCreateOrder> {
  final _formKey = GlobalKey<FormState>();
  final _orderName = TextEditingController();
  final _address = TextEditingController();

  bool selectLocation = false;
  bool checkAll = false;

  List<Product> products = [];
  List<ProductOrder> product = [];
  List<String> vegetables = [];

  GooglePlace googlePlace =
      GooglePlace('AIzaSyD8pN52ngRkDxuEjI4xYhMvixbJ0nIFIwE');

  bool noLocError = true;
  bool noDateError = true;
  bool noTimeError = true;
  bool showLocError = false;
  bool showDateTimeError = false;

  String? location;
  String locChoice = 'Default Address';
  final items = ['Default Address', 'Locate New Address'];
  final units = ['kg', 'g', 'pcs'];

  DateTime? selectedDate;
  String date = "";

  TimeOfDay? selectedTime;
  String time = "";

  int selectedUnit = 0;

  Timer? timer;
  double totalPrice = 0.0;

  void removeProduct(int index) {
    setState(() {
      product.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();

    products = widget.products;
    updateTotalPrice();
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();

    products.clear();
    super.dispose();
  }

  void checkLocation() {
    if (widget.user.newAddress != null) {
      if (mounted) {
        setState(() {
          noLocError = false;
        });
      }
    }
  }

  Future<void> saveOrder() async {
    final form = _formKey.currentState;

    form!.validate();
    if (noLocError) {
      setState(() {
        showLocError = true;
      });
    }

    if (noDateError || noTimeError) {
      setState(() {
        showDateTimeError = true;
      });
    }

    final tempAddress = Address(
        region: "Region X",
        province: 'Misamis Oriental',
        city: 'Tagoloan',
        barangay: 'Santa Ana',
        postal: 9001,
        precise: LatLng(8.5359226, 124.8019309),
        street: 'Zone 2');

    tempAddress.toCompleteAddress();

    final user = User(
        name: widget.user.name,
        fcmToken: widget.user.fcmToken,
        photoUrl: widget.user.photoUrl!);

    final order = EstabOrder(
        orderFrom: user,
        orderName: _orderName.text.trim(),
        products: widget.products,
        totalAmount: totalPrice,
        location: tempAddress,
        dateTime: DateTime(selectedDate!.year, selectedDate!.month,
            selectedDate!.day, selectedTime!.hour, selectedTime!.minute),
        createdAt: DateTime.now());

    if (!noLocError && !noDateError && !noTimeError) {
      ProductOrderApi.addOrder(userId: widget.user.id!, order: order)
          .whenComplete(() {
        ShoWInfo.showToast('Your order has been saved.', 3);
      });
    }
  }

  void updateTotalPrice() {
    double temp = 0;

    if (mounted) {
      setState(() {
        for (int i = 0; i < products.length; i++) {
          products[i].tPrice = products[i].post!.price * products[i].quantity;
          temp += products[i].tPrice!;
        }
        totalPrice = temp;
      });
    }
  }

  // Future<void> readJson() async {
  //   final String response =
  //       await rootBundle.loadString('assets/tags/veges.json');
  //   final data = await json.decode(response) as Map;

  //   vegetables =
  //       List.from(data['vegetables']).map((e) => e['name'].toString()).toList();
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: linkColor,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              const Text('CREATE ORDER',
                  style: TextStyle(
                    fontSize: 20,
                    color: linkColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  )),
            ],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      body: KeyboardVisibilityBuilder(
        builder: (p0, isKeyboardVisible) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding - 15, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _cTextField(
                                        controller: _orderName,
                                        hint: 'Order name',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please input your order name';
                                          }

                                          return null;
                                        }),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DottedBorder(
                                      color: linkColor.withOpacity(0.7),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(5),
                                      dashPattern: const [2, 2],
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          color: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Row(
                                                  children: [
                                                    buildLabel(
                                                        'Product',
                                                        0,
                                                        ((size.width - 72) *
                                                                0.36) +
                                                            34),
                                                    buildLabel(
                                                        'Qty.',
                                                        1,
                                                        (size.width - 72) *
                                                            0.24),
                                                    buildLabel(
                                                        'Price',
                                                        2,
                                                        (size.width - 72) *
                                                            0.24),
                                                  ],
                                                ),
                                              ),
                                              ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: products.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return buildProduct(
                                                        context,
                                                        products[index],
                                                        size.width,
                                                        index);
                                                  }),
                                              if (products.isEmpty)
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5),
                                                  child: Text(
                                                    'There are no products on your list. Go back to add.',
                                                    style: TextStyle(
                                                        color: linkColor,
                                                        fontSize: 12),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                            text: 'Total Amount:',
                                            style: TextStyle(
                                              color: linkColor,
                                              fontSize: 14,
                                            )),
                                        const WidgetSpan(
                                            child: SizedBox(
                                          width: 5,
                                        )),
                                        TextSpan(
                                            text:
                                                '${Utils.cn}${Utils.numberFormat.format(totalPrice)}',
                                            style: const TextStyle(
                                                color: linkColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold))
                                      ])),
                                    ),
                                    DottedBorder(
                                      color: linkColor.withOpacity(0.7),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(5),
                                      dashPattern: const [2, 2],
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5)),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectLocation = !selectLocation;
                                            });
                                          },
                                          child: Container(
                                            height: 36,
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            color: Colors.white,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  noLocError
                                                      ? "Location"
                                                      : locChoice,
                                                  style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      color: linkColor,
                                                      fontSize: 15),
                                                ),
                                                Icon(
                                                  !selectLocation
                                                      ? Icons
                                                          .keyboard_arrow_down
                                                      : Icons.keyboard_arrow_up,
                                                  color: linkColor,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (selectLocation)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: DottedBorder(
                                          color: linkColor.withOpacity(0.7),
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(5),
                                          dashPattern: const [2, 2],
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5)),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                height: 75,
                                                width: double.infinity,
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                color: Colors.white,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (noLocError) {
                                                          ShoWInfo.showAlertDialog(
                                                              context,
                                                              title:
                                                                  'No Default Address',
                                                              message:
                                                                  'You have no default address, please add your address.',
                                                              btnText: 'Okay',
                                                              onClick: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return UserLocateAddress(
                                                                saveAddress:
                                                                    (address) {},
                                                              );
                                                            }));
                                                          });
                                                        }
                                                        setState(() {
                                                          locChoice = items[0];
                                                          selectLocation =
                                                              false;
                                                          noLocError = false;
                                                          showLocError = false;
                                                        });
                                                      },
                                                      child: const SizedBox(
                                                        width: double.infinity,
                                                        child: Text(
                                                          'Default Address',
                                                          style: TextStyle(
                                                              color: linkColor,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(
                                                        thickness: 0.5,
                                                        color: linkColor),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UserLocateAddress(
                                                                saveAddress:
                                                                    (address) {},
                                                              ),
                                                            ));

                                                        setState(() {
                                                          locChoice = items[1];
                                                          selectLocation =
                                                              false;
                                                          noLocError = false;
                                                          showLocError = false;
                                                        });
                                                      },
                                                      child: const SizedBox(
                                                        width: double.infinity,
                                                        child: Text(
                                                            'Locate New Address',
                                                            style: TextStyle(
                                                                color:
                                                                    linkColor,
                                                                fontSize: 15)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (showLocError)
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 5),
                                        child: Text(
                                          'Please add your prefered delivery address.',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'Date and Time',
                                      style: TextStyle(
                                          color: linkColor, fontSize: 14),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    const Text(
                                      'Input what date and time you want your order to be delivered.',
                                      style: TextStyle(
                                          color: linkColor, fontSize: 11),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: DottedBorder(
                                        color: linkColor.withOpacity(0.7),
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(5),
                                        dashPattern: const [2, 2],
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                          child: Container(
                                            height: 75,
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            color: Colors.white,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialogPicker(context);
                                                    noDateError = false;

                                                    if (!noTimeError) {
                                                      setState(() {
                                                        showDateTimeError =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: date.isEmpty
                                                        ? const Text(
                                                            'MM/DD/YYYY',
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 15),
                                                          )
                                                        : Text(
                                                            date,
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        linkColor,
                                                                    fontSize:
                                                                        15),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: FDottedLine(
                                                    width: double.infinity,
                                                    dottedLength: 2,
                                                    space: 3,
                                                    color: linkColor
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialogTimePicker(
                                                        context);
                                                    noTimeError = false;

                                                    if (!noDateError) {
                                                      setState(() {
                                                        showDateTimeError =
                                                            false;
                                                      });
                                                    }
                                                  },
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: time.isEmpty
                                                        ? const Text('00:00 AM',
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor,
                                                                fontSize: 15))
                                                        : Text(time,
                                                            style:
                                                                const TextStyle(
                                                                    color:
                                                                        linkColor,
                                                                    fontSize:
                                                                        15)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (showDateTimeError)
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 5),
                                        child: Text(
                                          'Please provide your prefered delivery date and time.',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        ),
                                      )
                                  ],
                                ))
                          ]),
                    ),
                  ),
                ),
                if (!isKeyboardVisible)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        saveOrder();
                      },
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: linkColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Center(
                            child: Text(
                          'Save Order',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProduct(
      BuildContext context, Product product, double width, int index) {
    final newWidth = width - 72;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: Image.network(
              product.post!.images[0],
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, url, error) =>
                  const Icon(Icons.error, size: 12, color: linkColor),
            ),
          ),
          SizedBox(
            width: newWidth * 0.36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                product.post!.name,
                style: const TextStyle(
                    color: linkColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: width * 0.19,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    if (products[index].quantity > 1) {
                      timer = Timer.periodic(const Duration(milliseconds: 200),
                          (t) {
                        setState(() {
                          if (products[index].quantity > 1) {
                            products[index].quantity -= 1;
                            updateTotalPrice();
                          } else {
                            timer!.cancel();
                          }
                        });
                      });
                    }
                  },
                  onTap: () {
                    if (products[index].quantity > 1) {
                      if (mounted) {
                        setState(() {
                          products[index].quantity -= 1;
                          updateTotalPrice();
                        });
                      }
                    }
                  },
                  onTapUp: (TapUpDetails details) {
                    if (products[index].quantity > 1) {
                      timer!.cancel();
                    }
                  },
                  onTapCancel: () {
                    timer!.cancel();
                  },
                  child: Icon(FontAwesomeIcons.minus,
                      size: 16,
                      color: products[index].quantity <= 1
                          ? linkColor.withOpacity(0.5)
                          : linkColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  width: 22,
                  height: 20,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: linkColor)),
                  child: Center(
                    child: Text(
                      '${products[index].quantity}',
                      style: const TextStyle(
                          color: linkColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    if (products[index].quantity < 100) {
                      timer = Timer.periodic(const Duration(milliseconds: 200),
                          (t) {
                        setState(() {
                          if (products[index].quantity < 100) {
                            products[index].quantity += 1;
                            updateTotalPrice();
                          } else {
                            timer!.cancel();
                          }
                        });
                      });
                    }
                  },
                  onTapUp: (TapUpDetails details) {
                    if (products[index].quantity < 100) {
                      timer!.cancel();
                    }
                  },
                  onTapCancel: () {
                    timer!.cancel();
                  },
                  onTap: () {
                    if (products[index].quantity < 100) {
                      if (mounted) {
                        setState(() {
                          products[index].quantity += 1;
                          updateTotalPrice();
                        });
                      }
                    }
                  },
                  child: Icon(FontAwesomeIcons.plus,
                      size: 16,
                      color: products[index].quantity > 100
                          ? linkColor.withOpacity(0.5)
                          : linkColor))
            ]),
          ),
          Expanded(
            child: Center(
                child: Text(
                    '${Utils.cn}${Utils.numberFormat.format(products[index].tPrice!)}',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis))),
          ),
          GestureDetector(
            onTap: () {
              ShoWInfo.showUpDialog(context,
                  title: 'Remove Product',
                  message: 'Are you sure you want to remove this product?',
                  action1: 'Yes',
                  btn1: () {
                    products.remove(product);
                    ShoWInfo.showToast('Product has been removed.', 3);

                    updateTotalPrice();
                    Navigator.of(context).pop();
                  },
                  action2: 'Cancel',
                  btn2: () {
                    Navigator.of(context).pop();
                  });
            },
            child: const Center(
                child:
                    Icon(FontAwesomeIcons.xmark, size: 14, color: linkColor)),
          )
        ],
      ),
    );
  }

  Widget buildLabel(String label, int index, double space) {
    return SizedBox(
      width: space,
      child: index == 0
          ? Text(
              label,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: linkColor,
                  fontWeight: FontWeight.bold),
            )
          : Center(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  void showDialogPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    ).then((value) {
      setState(() {
        if (value == null) return;
        selectedDate = value;
        date = Utils.getFormattedDateSimple(value.millisecondsSinceEpoch);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  void showDialogTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        if (value == null) return;
        selectedTime = value;
        time = value.format(context);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  Widget _cTextField(
      {String? hint,
      String? suffix,
      required TextEditingController controller,
      TextInputType? type = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
            fontSize: 14, fontFamily: 'Roboto', color: linkColor),
        keyboardType: type,
        validator: validator,
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
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
