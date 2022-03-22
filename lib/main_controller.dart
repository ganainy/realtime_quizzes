import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../shared/shared.dart';
import 'models/question.dart';
import 'models/user.dart';

class MainController extends GetxController {
  var isOnlineObs = Rxn<bool>();

  //upload quiz to firebase
  /*void changeUserStatus(bool isOnline) {
    //get logged user data because it will be added to the quiz info that we will upload to firestore later
    usersCollection.doc(auth.currentUser?.email).update({
      'isOnline': isOnline,
    }).then((value) {
      debugPrint('update status success');
      isOnlineObs.value = isOnline;

      //get quizzes created by user
      debugPrint('getQuizzes()');

      //first get quizzesIds from user document then use it to fetch quizzes created by user
      usersCollection.doc(auth.currentUser?.email).get().then((value) {
        UserModel user = UserModel.fromJson(value.data());

        if (user.quizzesIds == null) {
          debugPrint('user created 0 quizzes ');
          return;
        }

        //change every quiz created by user status to online/offline based on user status
        quizzesCollection
            .where(FieldPath.documentId, whereIn: user.quizzesIds)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            QuizModelFireStore quizModelFireStore =
                QuizModelFireStore.fromJson(element.data());

            quizzesCollection
                .doc(quizModelFireStore.quizId.toString())
                .update({'isOnline': isOnline}).onError((error, stackTrace) {
              debugPrint('update single quiz state error: ' + error.toString());
              debugPrint('quiz id: ' + quizModelFireStore.quizId.toString());
            });
          });
        }).onError((error, stackTrace) {
          debugPrint('get user quizzes error: ' + error.toString());
        });
      }).onError((error, stackTrace) {
        debugPrint('update user status failed: ' + error.toString());
      });
    });
  }*/
}
