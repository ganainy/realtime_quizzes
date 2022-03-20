import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/quiz.dart';
import '../../shared/shared.dart';

class AvailableQuizzesController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var quizzes = [].obs;

  var errorLoadingQuestions = Rxn<String>();

  //get all online quizzes
  void findActiveQuizzes() {
    quizzesCollection.snapshots().listen((event) {
      quizzes.value = [];

      event.docs.forEach((quizJson) {
        QuizModelFireStore quiz = QuizModelFireStore.fromJson(quizJson.data());

        //get only online quizzes that arent made by logged in user
        if (quiz.isOnline != null && quiz.isOnline == true) {
          if (quiz.user!.email != auth.currentUser!.email) {
            quizzes.value.add(quiz);
            debugPrint('Quiz found-differnt');
          }
        }
      });
    });
  }
}
