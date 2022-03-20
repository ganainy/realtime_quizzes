import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/invite.dart';

import '../../models/quiz.dart';
import '../../shared/converters.dart';
import '../../shared/shared.dart';

class InviteController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;

  var errorLoadingQuestions = Rxn<String>();
  var selectedQuizObs = Rxn<QuizModelFireStore>();
  var timerCounter = Rxn<int>();

  sendPlayInvite(QuizModelFireStore selectedQuiz) {
    selectedQuizObs.value = selectedQuiz;

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
    });
  }

  Timer? _timer;
  final oneSec = const Duration(seconds: 1);

  void startTimer() {
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
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

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

  void observeInviteChanges() {
    //todo this method will listen to the invite and start game when other player accepts
  }
}
