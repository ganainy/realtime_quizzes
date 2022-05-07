import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:realtime_quizzes/screens/register/register.dart';
import 'package:realtime_quizzes/shared/constants.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import 'customization/theme.dart';
import 'layouts/home/home.dart';
import 'main_controller.dart';
import 'network/dio_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioHelper.init();
  await Firebase.initializeApp();

  Get.put(MainController());

  late Widget startWidget;

  //navigate to home or register based on auth state
  if (auth.currentUser != null) {
    startWidget = HomeScreen();
  } else {
    startWidget = RegisterScreen();
  }

  runApp(MyApp(startWidget));
}

class MyApp extends StatefulWidget {
  Widget startWidget;

  MyApp(this.startWidget, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState(startWidget);
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Widget startWidget;
  _MyAppState(this.startWidget);

  final MainController mainController = Get.put(MainController())
    ..changeUserStatus(true);

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      mainController.changeUserStatus(true);
      debugPrint('user online ');
    } else {
      debugPrint('user offline  ' + state.toString());
      mainController.changeUserStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz',
      locale: Locale('en', 'US'),
      translationsKeys: Constants.translation,
      theme: MyTheme.lighTheme,
      home: startWidget,
    );
  }
}
