import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';

import '../../models/question.dart';
import '../../shared/converters.dart';
import '../../shared/shared.dart';
import '../vs_random_quiz/vs_random_quiz_screen.dart';

class InviteController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;

  var errorLoadingQuestions = Rxn<String>();
  //var selectedQuizObs = Rxn<QuizModelFireStore>();
  var timerCounter = Rxn<int>();
 // var inviteObs = Rxn<InviteModel>();

 /* sendPlayInvite(QuizModelFireStore selectedQuiz) {
    selectedQuizObs.value = selectedQuiz;

    var players = [];
    players.add(PlayerModel(playerEmail: selectedQuiz.user?.email));
    players
        .add(PlayerModel(playerEmail: auth.currentUser?.email, isReady: true));
    InviteModel invite = InviteModel(selectedQuiz, players);
    inviteObs.value = invite;

    //add invite to invites
    invitesCollection
        .doc(selectedQuiz.quizId.toString())
        .set(inviteModelToJson(invite))
        .then((value) {
      debugPrint('invite success');
      startTimer();
      observeInviteChanges();
    }).onError((error, stackTrace) {
      debugPrint('invite error' + error.toString());
    });
  }*/

  Timer? _timer;
  final oneSec = const Duration(seconds: 1);

  void startTimer() {
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer();
    timerCounter.value = 10000; //todo 30sec

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timerCounter.value == 0) {
          //deleteInvite();
          debugPrint('timer ended');
        } else {
          timerCounter.value = timerCounter.value! - 1;
          debugPrint('counter:' + timerCounter.toString());
        }
      },
    );
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  /*void deleteInvite() {
    cancelTimer();
    invitesCollection
        .doc(selectedQuizObs.value?.quizId.toString())
        .delete()
        .then((value) {
      debugPrint('invite delete success ');
    }).onError((error, stackTrace) {
      debugPrint('invite delete error' + error.toString());
    });
  }*/

 /* void observeInviteChanges() {
    // this method will listen to the invite and start game when other player accepts
    invitesCollection
        .doc(inviteObs.value?.quiz.quizId.toString())
        .snapshots()
        .listen((inviteJson) {
      var invite = InviteModel.fromJson(inviteJson.data());
      invite.players.forEach((player) {
        //check if other player is ready
        if (player.playerEmail != auth.currentUser?.email && player.isReady) {
          debugPrint('other player ready');
          Get.off(
            () => VersusRandomQuizScreen(),
            arguments: inviteObs.value,
          );
        }
      });
    }).onError((error) {
      debugPrint('observe invite error' + error.toString());
    });
  }*/
}
