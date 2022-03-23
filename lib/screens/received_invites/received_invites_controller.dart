import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/shared/converters.dart';

import '../../models/question.dart';
import '../../shared/shared.dart';
import '../vs_random_quiz/vs_random_quiz_screen.dart';

class ReceivedInviteController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;

  var errorLoadingQuestions = Rxn<String>();
  //var selectedQuizObs = Rxn<QuizModelFireStore>();
  var receivedInvites = Rxn<List<dynamic>>();
  var timerCounter = Rxn<int>();

  startGame() {
    /*selectedQuizObs.value = selectedQuiz;

    var players = [];
    players.add(selectedQuiz.user?.email);
    players.add(auth.currentUser?.email);
    InviteModel invite = InviteModel(selectedQuiz, players);

    invitesCollection
        .doc(selectedQuiz.quizId.toString())
        .set(inviteModelToJson(invite))
        .then((value) {
      debugPrint('invite success');
      startTimer();
      observeInviteChanges();
    }).onError((error, stackTrace) {
      debugPrint('invite error' + error.toString());
    });*/
  }

  Timer? _timer;
  final oneSec = const Duration(seconds: 1);

  /*void startTimer() {
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer();
    timerCounter.value = 10; //todo 30sec

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timerCounter.value == 0) {
          deleteInvite();
          debugPrint('timer ended');
        } else {
          timerCounter.value = timerCounter.value! - 1;
          debugPrint('counter:' + timerCounter.toString());
        }
      },
    );
  }*/

  void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
/*
  void deleteInvite() {
    cancelTimer();
    invitesCollection
        .doc(selectedQuizObs.value?.quizId.toString())
        .delete()
        .then((value) {
      debugPrint('invite delete success ');
    }).onError((error, stackTrace) {
      debugPrint('invite delete error' + error.toString());
    });
  }

  void acceptInvite(int index) {
    InviteModel invite = receivedInvites.value?.elementAt(index);

    invite.players.forEach((player) {
      if (player.playerEmail == auth.currentUser?.email) {
        player.isReady = true;
      }
    });

    invitesCollection
        .doc(selectedQuizObs.value?.quizId.toString())
        .update(inviteModelToJson(invite))
        .then((value) {
      Get.off(
        () => VersusRandomQuizScreen(),
        arguments: invite,
      );
      debugPrint('invite accept success ');
    }).onError((error, stackTrace) {
      debugPrint('invite accept error' + error.toString());
    });
  }*/

  setInitialInvites(initialInvites) {
    receivedInvites.value = initialInvites;
  }
}