import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:realtime_quizzes/screens/register/register.dart';
import 'package:realtime_quizzes/shared/constants.dart';

import 'customization/theme.dart';
import 'network/dio_helper.dart';

void main() {
  DioHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      locale: Locale('en', 'US'),
      translationsKeys: Constants.translation,
      theme: MyTheme.lighTheme,
      home: const RegisterScreen(),
    );
  }
}
