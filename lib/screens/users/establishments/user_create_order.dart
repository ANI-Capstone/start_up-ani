import 'dart:convert';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/models/product_order.dart';
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

class UserCreateOrder extends StatefulWidget {
  const UserCreateOrder({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  _UserCreateOrderState createState() => _UserCreateOrderState();
}

class _UserCreateOrderState extends State<UserCreateOrder> {
  final _formKey = GlobalKey<FormState>();
  final _orderName = TextEditingController();
  final _productName = TextEditingController();
  final _productQnt = TextEditingController();
  final _address = TextEditingController();

  bool selectLocation = false;

  List<ProductOrder> product = [];
  List<String> vegetables = [];

  GooglePlace googlePlace =
      GooglePlace('AIzaSyD8pN52ngRkDxuEjI4xYhMvixbJ0nIFIwE');

  String? productError;
  bool isProductError = false;
  bool isQntError = false;
  bool noTagError = false;
  bool noLocError = true;
  bool noDateError = true;
  bool noTimeError = true;
  bool showLocError = false;
  bool showDateTimeError = false;

  String? location;
  String locChoice = 'Location';
  final items = ['Default Address', 'Locate New Address'];
  final units = ['kg', 'g', 'pcs'];

  late Future<DateTime?> selectedDate;
  String date = "";

  late Future<TimeOfDay?> selectedTime;
  String time = "";

  int selectedUnit = 0;

  void addProduct(String productName, int quantity, String unit, int unitId) {
    final newProduct = ProductOrder(
        productName: productName,
        quantity: quantity,
        unit: unit,
        unitId: unitId);

    setState(() {
      product.add(newProduct);
      _productName.text = '';
      _productQnt.text = '';
    });
  }

  void removeProduct(int index) {
    setState(() {
      product.removeAt(index);
    });
  }

  bool checkProductField() {
    if (_productName.text.isEmpty) {
      setState(() {
        productError = 'Input product name';
        isProductError = true;
      });
    }

    if (noTagError) {
      setState(() {
        productError = 'Product was not on the list';
      });
    }

    if (_productQnt.text.isEmpty) {
      setState(() {
        isQntError = true;
      });
    }

    return !isProductError && !noTagError && !isQntError;
  }

  @override
  void initState() {
    super.initState();

    readJson();
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/tags/veges.json');
    final data = await json.decode(response) as Map;

    vegetables =
        List.from(data['vegetables']).map((e) => e['name'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('CREATE ORDER',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              )),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding - 5, vertical: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  radius: 22,
                  backgroundColor: primaryColor,
                  backgroundImage:
                      Image.network(widget.user.photoUrl.toString()).image),
              const SizedBox(width: 10),
              Text(
                widget.user.name,
                style: const TextStyle(
                    color: linkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const Expanded(child: SizedBox(width: 1)),
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();

                  final form = _formKey.currentState;

                  if (!form!.validate()) {
                    return;
                  }

                  if (noLocError) {
                    setState(() {
                      showLocError = true;
                    });

                    return;
                  }

                  if (noDateError || noTimeError) {
                    setState(() {
                      showDateTimeError = true;
                    });
                    return;
                  }

                  if (product.isEmpty) {
                    ShoWInfo.showToast(
                        'Please add atleast one product to order.', 3);
                    return;
                  }

                  final tempAddress = Address(
                      region: "Region X",
                      province: 'Misamis Oriental',
                      city: 'Tagoloan',
                      barangay: 'Santa Ana',
                      postal: 9001,
                      precise: LatLng(8.5359226, 124.8019309),
                      street: 'Zone 2');

                  tempAddress.completeAddress =
                      Address.toCompleteAddress(tempAddress);

                  print(tempAddress.completeAddress);
                },
                child: const Text('ORDER',
                    style: TextStyle(
                        color: linkColor, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(
              height: 16,
            ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TypeAheadField(
                              minCharsForSuggestions: 1,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _productName,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: linkColor),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  errorText: productError,
                                  suffix: noTagError
                                      ? const FaIcon(
                                          FontAwesomeIcons.xmark,
                                          color: redColor,
                                          size: 14,
                                        )
                                      : null,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 13, 10, 13),
                                  hintText: 'Add product name',
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: primaryColor),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5)),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    if (noTagError) {
                                      productError =
                                          'Product was not on the list';
                                    } else {
                                      productError = null;
                                    }
                                  });
                                },
                              ),
                              suggestionsCallback: (pattern) async {
                                List<String> matches = <String>[];
                                matches.addAll(vegetables);

                                matches.retainWhere((s) {
                                  return s
                                      .toLowerCase()
                                      .contains(pattern.toLowerCase());
                                });

                                noTagError = matches.isEmpty ? true : false;

                                return matches;
                              },
                              noItemsFoundBuilder: (context) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Text(
                                    'No items found!',
                                    style: TextStyle(
                                        color: linkColor, fontSize: 14),
                                  ),
                                );
                              },
                              itemBuilder: (context, suggestion) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Text(
                                    suggestion.toString(),
                                    style: const TextStyle(
                                        color: primaryColor, fontSize: 15),
                                  ),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                setState(() {
                                  _productName.text = suggestion.toString();
                                  productError = null;
                                });
                              },
                              itemSeparatorBuilder: ((context, index) =>
                                  const Divider()),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _productQnt,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  color: linkColor),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                setState(() {
                                  isQntError = false;
                                });
                              },
                              onSaved: (value) {
                                _productName.text = value!;
                              },
                              decoration: InputDecoration(
                                  errorText: isQntError ? "Required" : null,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 13, 10, 13),
                                  hintText: 'Qty.',
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: primaryColor),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  suffixText: units[selectedUnit],
                                  suffixStyle: const TextStyle(
                                      fontSize: 14, color: linkColor)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.only(right: 14, left: 2),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5))),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 20,
                              height: 50,
                              child: PopupMenuButton(
                                  constraints: BoxConstraints.tight(
                                      const Size(120, 120)),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  onSelected: (value) {},
                                  position: PopupMenuPosition.under,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context) => [
                                        _buildMenuItems(
                                            label: 'Kilograms', value: 0),
                                        _buildMenuItems(
                                            label: 'Grams', value: 1),
                                        _buildMenuItems(label: 'Pcs.', value: 2)
                                      ],
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: linkColor,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                    if (product.isNotEmpty)
                      ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: product.length,
                        itemBuilder: (context, index) {
                          return _buildProduct(product[index], index);
                        },
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    DottedBorder(
                      color: linkColor.withOpacity(0.7),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [2, 2],
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: GestureDetector(
                          onTap: () {
                            if (checkProductField()) {
                              addProduct(
                                  _productName.text,
                                  int.parse(_productQnt.text),
                                  units[selectedUnit],
                                  selectedUnit);

                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          child: const SizedBox(
                            height: 36,
                            width: double.infinity,
                            child: Center(
                                child: FaIcon(
                              FontAwesomeIcons.circlePlus,
                              color: linkColor,
                              size: 18,
                            )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DottedBorder(
                      color: linkColor.withOpacity(0.7),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      dashPattern: const [2, 2],
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  locChoice,
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      color: linkColor,
                                      fontSize: 15),
                                ),
                                Icon(
                                  !selectLocation
                                      ? Icons.keyboard_arrow_down
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
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: DottedBorder(
                          color: linkColor.withOpacity(0.7),
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(5),
                          dashPattern: const [2, 2],
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 75,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          locChoice = items[0];
                                          selectLocation = false;
                                          noLocError = false;
                                          showLocError = false;
                                        });
                                      },
                                      child: const SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          'Default Address',
                                          style: TextStyle(
                                              color: linkColor, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                        thickness: 0.5, color: linkColor),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserLocateAddress(),
                                            ));

                                        setState(() {
                                          locChoice = items[1];
                                          selectLocation = false;
                                          noLocError = false;
                                          showLocError = false;
                                        });
                                      },
                                      child: const SizedBox(
                                        width: double.infinity,
                                        child: Text('Locate New Address',
                                            style: TextStyle(
                                                color: linkColor,
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
                        padding: EdgeInsets.only(top: 10, left: 5),
                        child: Text(
                          'Please select your prefered delivery address.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Date and Time',
                      style: TextStyle(color: linkColor, fontSize: 14),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    const Text(
                      'Input what date and time you want your order to be delivered.',
                      style: TextStyle(color: linkColor, fontSize: 11),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: DottedBorder(
                        color: linkColor.withOpacity(0.7),
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(5),
                        dashPattern: const [2, 2],
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Container(
                            height: 75,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialogPicker(context);
                                    noDateError = false;

                                    if (!noTimeError) {
                                      setState(() {
                                        showDateTimeError = false;
                                      });
                                    }
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: date.isEmpty
                                        ? const Text(
                                            'MM/DD/YYYY',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 15),
                                          )
                                        : Text(
                                            date,
                                            style: const TextStyle(
                                                color: linkColor, fontSize: 15),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: FDottedLine(
                                    width: double.infinity,
                                    dottedLength: 2,
                                    space: 3,
                                    color: linkColor.withOpacity(0.7),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialogTimePicker(context);
                                    noTimeError = false;

                                    if (!noDateError) {
                                      setState(() {
                                        showDateTimeError = false;
                                      });
                                    }
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: time.isEmpty
                                        ? const Text('00:00 AM',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 15))
                                        : Text(time,
                                            style: const TextStyle(
                                                color: linkColor,
                                                fontSize: 15)),
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
                        padding: EdgeInsets.only(top: 10, left: 5),
                        child: Text(
                          'Please provide your prefered delivery date and time.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      )
                  ],
                ))
          ]),
        ),
      ),
    );
  }

  PopupMenuItem _buildMenuItems({required String label, required int value}) {
    return PopupMenuItem(
        value: value,
        height: 0,
        onTap: () {
          setState(() {
            selectedUnit = value;
          });
        },
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
              color: value == selectedUnit ? primaryColor : null,
              borderRadius: BorderRadius.circular(3)),
          child: Text(
            label,
            style: const TextStyle(
                color: linkColor, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ));
  }

  void showDialogPicker(BuildContext context) {
    selectedDate = showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    selectedDate.then((value) {
      setState(() {
        if (value == null) return;
        date = Utils.getFormattedDateSimple(value.millisecondsSinceEpoch);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  void showDialogTimePicker(BuildContext context) {
    selectedTime = showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    selectedTime.then((value) {
      setState(() {
        if (value == null) return;
        time = value.format(context);
      });
    }, onError: (error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  Widget _locationDropdown({
    required String hint,
    required List<String> items,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        padding: EdgeInsets.zero,
        hint: Text(hint,
            style: const TextStyle(
              color: linkColor,
            )),
        value: location,
        isExpanded: true,
        elevation: 0,
        dropdownColor: Colors.white,
        menuMaxHeight: 120,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: linkColor,
        ),
        items: items.asMap().entries.map((item) {
          return DropdownMenuItem(
            value: item.value,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.value,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  FaIcon(
                    item.key == 0
                        ? FontAwesomeIcons.locationDot
                        : FontAwesomeIcons.magnifyingGlass,
                    size: 18,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            location = newValue!;
          });

          if (newValue == 'Locate New Address') {
          } else {}
        },
      ),
    );
  }

  Widget _buildProduct(ProductOrder product, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
                child: Text(
              product.productName,
              style: const TextStyle(color: linkColor, fontSize: 14),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: FDottedLine(
                height: 40,
                dottedLength: 2,
                space: 3,
                color: linkColor.withOpacity(0.7),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: 80,
              child: Text(
                '${product.quantity} ${product.unit}',
                style: const TextStyle(
                    color: linkColor, overflow: TextOverflow.ellipsis),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () {
                  removeProduct(index);
                },
                child: const FaIcon(
                  FontAwesomeIcons.xmark,
                  color: linkColor,
                  size: 16,
                ),
              ),
            )
          ]),
        ),
      ),
    );
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
