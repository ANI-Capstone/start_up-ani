import 'package:ani_capstone/providers/google_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ani_capstone/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'constants.dart';

int? initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializeApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeApp.then((value) => FlutterNativeSplash.remove());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleProvider(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ANI',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: primaryColor,
            fontFamily: 'Roboto',
          ),
          initialRoute: initScreen == null ? 'onboard' : 'home',
          routes: {
            'home': (context) => const HomePage(),
            'onboard': (context) => const OnBoardPage(),
          }));
}
