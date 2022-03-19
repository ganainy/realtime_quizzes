import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:realtime_quizzes/screens/home/home.dart';
import 'package:realtime_quizzes/screens/register/register.dart';
import 'package:realtime_quizzes/shared/constants.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import 'customization/theme.dart';
import 'network/dio_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioHelper.init();
  await Firebase.initializeApp();

  late Widget startWidget;

  //navigate to home or register based on auth state
  if (auth.currentUser != null) {
    startWidget = HomeScreen();
  } else {
    startWidget = RegisterScreen();
  }

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Quiz',
    locale: Locale('en', 'US'),
    translationsKeys: Constants.translation,
    theme: MyTheme.lighTheme,
    home: startWidget,
  ));
}
