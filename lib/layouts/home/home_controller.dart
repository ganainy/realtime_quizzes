import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';

import '../../models/question.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class HomeController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var quizzes = [].obs;
  var invites = [].obs;

  var errorLoadingQuestions = Rxn<String>();

  var bottomSelectedIndex = 0.obs;

  //get quizzes created by user
 /* getQuizzes() {
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
        //المشكله هنا
        invite.players.forEach((player) {
          //show only as invite if user email is in invite players list and
          // if the invite quiz not made by user
          if (invite.quiz.user?.email != auth.currentUser?.email) {
            if (player.playerEmail == auth.currentUser?.email) {
              debugPrint('  wtf: ' + player.playerEmail.toString());
              debugPrint('  wtf: ${auth.currentUser?.email.toString()}');
              debugPrint('  wtf: ${invite.quiz.user?.email}');

              invites.value.add(invite);
              debugPrint('  invite found: ' + invites.value.length.toString());
            }
          }
        });
      });
    }).onError((error) {
      debugPrint('error getting invites: ' + error.toString());
    });
  }*/
}
