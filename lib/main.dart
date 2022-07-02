import 'package:ani_capstone/providers/google_sign_in.dart';
import 'package:ani_capstone/screens/auth/sign_up_1.dart';
import 'package:ani_capstone/screens/home_page.dart';
import 'package:ani_capstone/screens/user_type_select.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializeApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeApp;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ANI',
        theme: ThemeData(
          splashColor: Colors.green,
          primaryColor: primaryColor,
          fontFamily: 'Roboto',
          textTheme: Theme.of(context).textTheme.apply(displayColor: textColor),
        ),
        home: UserSelect(),
      ));
}
