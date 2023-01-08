// import 'package:ani_capstone/models/user_data.dart';
// import 'package:ani_capstone/api/firebase_message.dart';
// import 'package:ani_capstone/constants.dart';
// import 'package:ani_capstone/models/product.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class ConsumerBag extends StatefulWidget {
//   List<Product> userBag;
//   String chatPathId;
//   UserData user;
//   int orderStatus;

//   ConsumerBag(
//       {Key? key,
//       required this.chatPathId,
//       required this.user,
//       required this.userBag,
//       required this.orderStatus})
//       : super(key: key);

//   @override
//   _ConsumerBagState createState() => _ConsumerBagState();
// }

// class _ConsumerBagState extends State<ConsumerBag> {
//   bool expanded = true;

//   final expandedIcon = FontAwesomeIcons.chevronUp;
//   final notExpandedIcon = FontAwesomeIcons.chevronDown;

//   IconData expandIcon = FontAwesomeIcons.chevronUp;

//   void onExpand() {
//     if (mounted) {
//       setState(() {
//         expandIcon = !expanded ? expandedIcon : notExpandedIcon;
//       });

//       expanded = !expanded;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.userBag.isEmpty
//         ? const SizedBox()
//         : Container(
//             decoration: BoxDecoration(color: bannerBgColor),
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (widget.user.userTypeId == 1)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 12, left: 18),
//                       child: Text(
//                         widget.orderStatus != 1
//                             ? 'Please prepare your product for pick up.'
//                             : 'This user wants to buy your product(s).',
//                         style: const TextStyle(
//                             color: linkColor,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   Stack(
//                     children: [
//                       Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.all(20),
//                               child: FaIcon(
//                                 FontAwesomeIcons.bagShopping,
//                                 color: linkColor,
//                                 size: 30,
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Padding(
//                                     padding: EdgeInsets.only(top: 16),
//                                     child: Text(
//                                       'PRODUCT:',
//                                       style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                   ),
//                                   // Padding(
//                                   //   padding: const EdgeInsets.only(
//                                   //       top: 5, bottom: 5),
//                                   //   child: ListView(
//                                   //     shrinkWrap: true,
//                                   //     children: widget.userBag
//                                   //         .take(expanded
//                                   //             ? widget.userBag.length
//                                   //             : 2)
//                                   //         .map((product) =>
//                                   //             buildProduct(product))
//                                   //         .toList(),
//                                   //   ),
//                                   // ),
//                                   const SizedBox(height: 18),
//                                   if (expanded)
//                                     const SizedBox(
//                                       height: 5,
//                                     )
//                                 ],
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 onExpand();
//                               },
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.only(top: 12, right: 18),
//                                 child: FaIcon(
//                                   expandIcon,
//                                   color: linkColor,
//                                   size: 18,
//                                 ),
//                               ),
//                             )
//                           ]),
//                       buildActions()
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }

//   Widget buildActions() {
//     if (widget.user.userTypeId == 1) {
//       if (widget.orderStatus == 1) {
//         return Positioned(
//           bottom: 0,
//           right: 20,
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   showUpDialog(context,
//                       title: 'Accept Order',
//                       message: 'Are you sure you want to accept the order?',
//                       action1: 'Yes',
//                       action2: 'Cancel', btn1: () {
//                     if (mounted) {
//                       setState(() {
//                         widget.orderStatus = 2;
//                       });
//                     }
//                     Navigator.pop(context, true);
//                   }, btn2: () {
//                     Navigator.pop(context, true);
//                   });
//                 },
//                 child: const Text(
//                   'Accept Order',
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: linkColor,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//               const SizedBox(
//                 width: 15,
//               ),
//               GestureDetector(
//                 onTap: () {},
//                 child: const Text(
//                   'Deny',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                 ),
//               )
//             ],
//           ),
//         );
//       } else {
//         return Positioned(
//           bottom: 0,
//           right: 20,
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context, true);
//                 },
//                 child: const Text(
//                   'Close',
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: linkColor,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//               const SizedBox(
//                 width: 15,
//               ),
//             ],
//           ),
//         );
//       }
//     }

//     if (widget.orderStatus == 1) {
//       return Positioned(
//         bottom: 0,
//         right: 20,
//         child: Row(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showUpDialog(context,
//                     title: 'Order Confirmation',
//                     message:
//                         'The farmer will be notified so you can start negotiating.',
//                     action1: 'Confirm',
//                     action2: 'Cancel',
//                     btn1: () {}, btn2: () {
//                   Navigator.pop(context, true);
//                 });
//               },
//               child: const Text(
//                 'Buy',
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: linkColor,
//                     fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(
//               width: 15,
//             ),
//             GestureDetector(
//               onTap: () {
//                 showUpDialog(context,
//                     title: 'Cancel Order',
//                     message:
//                         'Are you sure you want to remove all of your orders?',
//                     action1: 'Yes',
//                     action2: 'Cancel', btn1: () {
//                   if (mounted) {
//                     setState(() {
//                       widget.userBag.clear();
//                     });

//                     FirebaseMessageApi.removeAllToBag(
//                         chatPathId: widget.chatPathId);
//                   }

//                   Navigator.pop(context, true);
//                 }, btn2: () {
//                   Navigator.pop(context, true);
//                 });
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             )
//           ],
//         ),
//       );
//     } else {
//       return Positioned(
//         bottom: 0,
//         right: 20,
//         child: Row(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 showUpDialog(context,
//                     title: 'Order Confirmation',
//                     message:
//                         'The farmer will be notified so you can start negotiating.',
//                     action1: 'Confirm',
//                     action2: 'Cancel',
//                     btn1: () {}, btn2: () {
//                   Navigator.pop(context, true);
//                 });
//               },
//               child: const Text(
//                 'Buy',
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: linkColor,
//                     fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(
//               width: 15,
//             ),
//             GestureDetector(
//               onTap: () {
//                 showUpDialog(context,
//                     title: 'Cancel Order',
//                     message:
//                         'Are you sure you want to remove all of your orders?',
//                     action1: 'Yes',
//                     action2: 'Cancel', btn1: () {
//                   if (mounted) {
//                     setState(() {
//                       widget.userBag.clear();
//                     });

//                     FirebaseMessageApi.removeAllToBag(
//                         chatPathId: widget.chatPathId);
//                   }

//                   Navigator.pop(context, true);
//                 }, btn2: () {
//                   Navigator.pop(context, true);
//                 });
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//               ),
//             )
//           ],
//         ),
//       );
//     }
//   }

//   // Widget buildProduct(Product product) {
//   //   return Row(
//   //     children: [
//   //       Text(
//   //         product.post.name.length > 15
//   //             ? '\u2022 ${product.post.name.characters.take(12)}'
//   //             : '\u2022 ${product.post.name}',
//   //         style: const TextStyle(
//   //             fontSize: 14, color: linkColor, fontWeight: FontWeight.bold),
//   //       ),
//   //       const SizedBox(width: 5),
//   //       Text(
//   //         '- \u20B1${product.post.price}/${buildUnit(product.post.unit)}',
//   //         style: const TextStyle(
//   //             fontSize: 14, color: linkColor, fontWeight: FontWeight.w500),
//   //       ),
//   //       const SizedBox(width: 10),
//   //       if (widget.user.userTypeId == 2)
//   //         GestureDetector(
//   //             onTap: () {
//   //               if (mounted) {
//   //                 setState(() {
//   //                   widget.userBag.removeWhere((element) {
//   //                     return element.post.postId == product.post.postId;
//   //                   });
//   //                 });
//   //               }

//   //               FirebaseMessageApi.removeToBag(
//   //                   chatPathId: widget.chatPathId,
//   //                   productId: product.post.postId!);
//   //             },
//   //             child: const Icon(FontAwesomeIcons.xmark,
//   //                 color: linkColor, size: 12))
//   //     ],
//   //   );
//   // }

//   String buildUnit(String unit) {
//     if (unit == 'Gram') {
//       return 'g';
//     } else if (unit == 'Pound') {
//       return 'lb';
//     } else {
//       return 'kl';
//     }
//   }

//   void showUpDialog(BuildContext context,
//       {required String title,
//       required String message,
//       required String action1,
//       required String action2,
//       required VoidCallback btn1,
//       required VoidCallback btn2}) {
//     Widget button1 = TextButton(
//       onPressed: () {
//         btn1();
//       },
//       child: Text(action1,
//           style:
//               const TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
//     );

//     Widget button2 = TextButton(
//       onPressed: () {
//         btn2();
//       },
//       child: Text(action2,
//           style:
//               const TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
//     );

//     AlertDialog alert = AlertDialog(
//       title: Text(
//         title,
//         style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//       ),
//       content: Text(
//         message,
//         style: const TextStyle(fontSize: 15),
//       ),
//       actions: [button1, button2],
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(15.0))),
//     );

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }
