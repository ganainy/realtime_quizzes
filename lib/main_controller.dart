import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../shared/shared.dart';

class MainController extends GetxController {
  var isOnlineObs = Rxn<bool>();

  void changeUserStatus(bool isOnline) {
    //set user as online and offline based on if using app or not
    usersCollection.doc(auth.currentUser?.email).update({
      'isOnline': isOnline,
    }).then((value) {
      debugPrint('update status success');
      isOnlineObs.value = isOnline;
    });
  }
}
