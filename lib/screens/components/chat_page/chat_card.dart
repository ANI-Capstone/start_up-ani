// import 'package:ani_capstone/constants.dart';
// import 'package:ani_capstone/models/message.dart';
// import 'package:flutter/material.dart';

// class ChatCard extends StatelessWidget {
//   Message message;

//   ChatCard({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Container(
//         height: 80,
//         decoration: const BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.all(Radius.circular(15))),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                   backgroundImage: NetworkImage(message.author.photoUrl),
//                   radius: 28),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           (message.author.name.length < 20)
//                               ? message.author.name
//                               : '${message.author.name.toString().characters.take(20)}...',
//                           style: const TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: linkColor),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                             (message.message.length < 58)
//                                 ? message.message
//                                 : '${message.message.toString().characters.take(58)}...',
//                             style: TextStyle(
//                                 fontFamily: 'Roboto',
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: linkColor.withOpacity(0.8)))
//                       ]),
//                 ),
//               ),
//               Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     message.timeStamp,
//                     style: const TextStyle(color: linkColor, fontSize: 13),
//                   ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
