import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/product_order.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';

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

  String? location;
  String locChoice = 'Location';
  var items = ['Default Address', 'Locate New Address'];

  void addProduct(String productName, int quantity, int unit) {
    final newProduct =
        ProductOrder(productName: productName, quantity: quantity, unit: unit);

    setState(() {
      product.add(newProduct);
    });
  }

  void removeProduct(int index) {
    setState(() {
      product.removeAt(index);
    });
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
                    _cTextField(controller: _orderName, hint: 'Order name'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                                controller: _productName,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: linkColor),
                                keyboardType: TextInputType.text,
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(errorText: 'Required'),
                                  ],
                                ),
                                onSaved: (value) {
                                  _productName.text = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 13, 10, 13),
                                  hintText: 'Add product name',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: primaryColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5)),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              controller: _productQnt,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  color: linkColor),
                              keyboardType: TextInputType.text,
                              validator: MultiValidator(
                                [
                                  RequiredValidator(errorText: 'Required'),
                                ],
                              ),
                              onSaved: (value) {
                                _productName.text = value!;
                              },
                              decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(10, 13, 10, 13),
                                  hintText: 'Quantity',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: primaryColor),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5)),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.white,
                                  isDense: true,
                                  suffixText: 'kg',
                                  suffixStyle: TextStyle(
                                      fontSize: 14, color: primaryColor)),
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
                            final formState = _formKey.currentState!;

                            if (formState.validate()) {
                              addProduct(_productName.text,
                                  int.parse(_productQnt.text), 0);
                              FocusManager.instance.primaryFocus?.unfocus();
                              formState.reset();
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
                            padding: EdgeInsets.symmetric(horizontal: 10),
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
                                padding: EdgeInsets.symmetric(horizontal: 10),
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
                                        setState(() {
                                          locChoice = items[1];
                                          selectLocation = false;
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
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Date and Time',
                      style: TextStyle(color: linkColor, fontSize: 13),
                    ),
                    Text(
                      '(Input what date and time you want your products to be delivered.)',
                      style: TextStyle(color: linkColor, fontSize: 11),
                    ),
                  ],
                ))
          ]),
        ),
      ),
    );
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
              decoration: BoxDecoration(color: Colors.black),
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
              width: 100,
              child: Text(
                '${product.quantity} ${product.unit == 0 ? 'kg.' : 'pcs.'}',
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
      String? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
