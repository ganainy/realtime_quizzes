import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/category.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/screens/home/home.dart';

import '../../models/difficulty.dart';
import '../../models/quiz.dart';
import '../../models/user.dart';
import '../../network/dio_helper.dart';
import '../../shared/shared.dart';
import '../single_player_quiz/single_player_quiz_screen.dart';

class CreateQuizController extends GetxController {
  var numOfQuestions = 10.00.obs;
  var selectedCategory = Category('general_knowledge'.tr, 9).obs;
  var selectedDifficulty = Difficulty('medium'.tr, 'medium').obs;
  var downloadState = DownloadState.INITIAL.obs;

  var errorLoadingQuestions = Rxn<String>();
  var quizModel = Rxn<QuizModelApi>();

  fetchQuiz() {
    downloadState.value = DownloadState.LOADING;

    QuizSpecs quizSpecs = QuizSpecs(numOfQuestions.value.toInt(),
        selectedCategory.value, selectedDifficulty.value);

    //download quiz from api
    DioHelper.getQuestions(queryParams: quizSpecs.toMap()).then((json) {
      quizModel.value = QuizModelApi.fromJson(json.data);
      quizModel.value?.quizSpecs = quizSpecs;

      if (quizModel.value!.questions.isEmpty) {
        errorLoadingQuestions.value = 'error_loading_quiz'.tr;
        downloadState.value = DownloadState.ERROR;

        debugPrint('error_loading_quiz from api');
        //todo show error loading questions
      } else {
        uploadQuiz();
      }
    }).onError((error, stackTrace) {
      //todo show error loading questions
      downloadState.value = DownloadState.ERROR;
      errorLoadingQuestions.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
      debugPrint('error_loading_quiz from api: ' + error.toString());
    });
  }

  //upload quiz to firebase
  void uploadQuiz() {
    //get logged user data because it will be added to the quiz info that we will upload to firestore later
    usersCollection.doc(auth.currentUser?.email).get().then((value) {
      debugPrint('sucess' + value.data().toString());
      UserModel user = UserModel.fromJson(value.data());
      quizModel.value?.user = user;

      //upload quiz to firestore
      quizzesCollection
          .doc(quizModel.value?.quizId.toString())
          .set(quizModel.value?.quizModelApiToJson())
          .then((value) {
        debugPrint('firestore save quiz success ');
        //saved quiz id to the user
        usersCollection.doc(auth.currentUser?.email).update({
          "quizzesIds":
              FieldValue.arrayUnion([quizModel.value?.quizId.toString()])
        }).then((value) {
          debugPrint('save created quiz id success ');
          Get.off(
            () => HomeScreen(),
          );
        }).onError((error, stackTrace) {
          downloadState.value = DownloadState.ERROR;
          debugPrint('save created quiz id error ' + error.toString());
        });
      }).onError((error, stackTrace) {
        downloadState.value = DownloadState.ERROR;
        debugPrint('firestore error : ' + error.toString());
      });
    }).onError((error, stackTrace) {
      downloadState.value = DownloadState.ERROR;
      debugPrint('Something went wrong ' + error.toString());
    });

    //questionsModel.toMap()
  }

  startSinglePlayer() {
    Get.to(() => SinglePlayerQuizScreen(),
        arguments: QuizSpecs(numOfQuestions.value.toInt(),
            selectedCategory.value, selectedDifficulty.value));
  }
}
