import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/invite.dart';

import '../../models/quiz.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class HomeController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var quizzes = [].obs;
  var invites = [].obs;

  var errorLoadingQuestions = Rxn<String>();

  //get quizzes created by user
  getQuizzes() {
    debugPrint('getQuizzes()');

    //first get quizzesIds from user document then use it to fetch quizzess created by user
    usersCollection.doc(auth.currentUser?.email).get().then((value) {
      UserModel user = UserModel.fromJson(value.data());

      if (user.quizzesIds == null) {
        debugPrint('user created 0 quizzes ');
        return;
      }

      quizzesCollection
          .where(FieldPath.documentId, whereIn: user.quizzesIds)
          .snapshots()
          .listen((event) {
        quizzes.value = [];

        event.docs.forEach((element) {
          QuizModelFireStore quizModelFireStore =
              QuizModelFireStore.fromJson(element.data());
          // quizzes.value.add(quizModelFireStore);
          quizzes.value.add(quizModelFireStore);
          debugPrint('get quizzes success ' + quizzes.length.toString());
        });
      }).onError((error) {
        debugPrint('get quizzes error: ' + error.toString());
      });
    }).onError((error, stackTrace) {
      debugPrint('get quizzes error: ' + error.toString());
    });
  }

  observeInvites() {
    invitesCollection.snapshots().listen((event) {
      invites.value = [];
      event.docs.forEach((inviteJson) {
        var invite = InviteModel.fromJson(inviteJson);
        if (invite.players.contains(auth.currentUser?.email)) {
          invites.value.add(invite);
          debugPrint('  invite found: ' + invites.value.length.toString());
        }
      });
    }).onError((error) {
      debugPrint('error getting invites: ' + error.toString());
    });
  }
}
