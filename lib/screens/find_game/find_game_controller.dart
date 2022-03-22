import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/screens/vs_random_quiz/vs_random_quiz_screen.dart';
import 'package:realtime_quizzes/shared/converters.dart';

import '../../models/api.dart';
import '../../models/queue_entry.dart';
import '../../models/question.dart';
import '../../models/user.dart';
import '../../network/dio_helper.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';

class FindGameController extends GetxController {
  // var timerCounter = Rxn<int>();

  var numOfQuestions = 10.00.obs;
  var selectedCategory = 'general_knowledge'.tr.obs;
  var selectedDifficulty = 'medium'.tr.obs;
  var downloadState = DownloadState.INITIAL.obs;
  var isInQueue = false.obs;

  var errorLoadingQuestions = Rxn<String>();
  var queueEntryIdObs= Rxn<String>();
  var queueEntryModelObs= Rxn<QueueEntryModel>();
  StreamSubscription? queueEntryListener;


  void enterQueue(BuildContext context) {
    queueEntryIdObs.value=auth.currentUser?.email;
    var players = [
      PlayerModel(playerEmail: auth.currentUser?.email, isReady: true)
    ];
    var queueEntryModel = QueueEntryModel(
        selectedDifficulty.value,
        selectedCategory.value,
        numOfQuestions.value.toInt(),
        auth.currentUser?.email,
        players);

    var queueEntryModelJson = queueEntryModelToJson(queueEntryModel);

    queueCollection
        .doc(queueEntryModel.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      debugPrint('scenario 2: created queue entry and in queue');

      downloadState.value = DownloadState.SUCCESS;
      isInQueue.value = true;
      inQueueDialog(context);
      observeQueueChanges(context);

    }).onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('scenario 2: create queue entry error :' + error.toString());
    });
  }

  inQueueDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Play offline"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("In queue"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "Game will start once we find another player with same search paramaters as you"),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  foundMatchDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Found match"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Game will start shortly"),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
      actions: [],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void cancelQueue() {
    queueCollection.doc(auth.currentUser?.email).delete().then((value) {
      isInQueue.value == false;
      debugPrint('left queue');
    }).onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('leave queue error :' + error.toString());
    });
  }

  //this method will be triggered if another player is matched with this player
  void observeQueueChanges(BuildContext context) {
     queueEntryListener=queueCollection
        .doc(auth.currentUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.players.length > 1) {
        Get.back();
        foundMatchDialog(context);
        startGame();
        debugPrint('scenario 2: another play is add to my entry, match should start');
      } else {
        debugPrint('scenario 2: still one player: ' + queueEntry.players.length.toString());
      }
    });

     queueEntryListener?.onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('scenario 2: observing my queue entry error :' + error.toString());
    });
  }

  //this method will be triggered if this player is matched with another player
  void searchAvailableQueues(BuildContext context) {

    //first try to find alreay existing matching queue entry
       // .where('numberOfQuestions', isEqualTo: numOfQuestions.value.toInt())
    queueCollection.where('queueEntryId', isNotEqualTo: (auth.currentUser?.email))
       // .where('difficulty', isEqualTo: ((selectedDifficulty.value)))
       // .where('category', isEqualTo: ((selectedCategory.value)))
        .limit(1)
    .get().then((queueEntrysJson) {

      if (queueEntrysJson.docs.isEmpty) {
        debugPrint('Scenario 1: No matches found => Goto scenario 2');
        //no suitable match found
        enterQueue(context);
      }else{
        //found suitable match, add to list of players

        queueEntrysJson.docs.forEach((queueEntryJson) {

          debugPrint('Scenario 1: match found ');
          //found successful match
          var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
          queueEntryIdObs.value=queueEntry.queueEntryId;
          debugPrint('wtf: ${queueEntryJson.data().toString()}');
          addPlayerToGamePlayers(context);
        });

    }


    }).onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('observeOtherQueues error :' + error.toString());
      });



  }

  //add the player to the list of players of the found queue entry to begin match
  void addPlayerToGamePlayers( BuildContext context) {
    var players = [
      PlayerModel(playerEmail: auth.currentUser?.email, isReady: true),
      PlayerModel(playerEmail: queueEntryIdObs.value, isReady: true),
    ];

    var queueEntryModel = QueueEntryModel(
        selectedDifficulty.value,
        selectedCategory.value,
        numOfQuestions.value.toInt(),
        queueEntryIdObs.value,
        players);

    queueEntryModelObs.value=queueEntryModel;

    var queueEntryModelJson = queueEntryModelToJson(queueEntryModel);

    queueCollection
        .doc(queueEntryModel.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      downloadState.value = DownloadState.SUCCESS;
      Get.back();
      foundMatchDialog(context);
      startGame();
      debugPrint('Scenario 1: add player to game players now start match');
    }).onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('Scenario 1: add player to game players error :' + error.toString());
    });
  }

  //download quiz and begin match
  void startGame() {


    //both players will call this method, so only the user who created the queueEntry will
    //load quiz from Api then upload it to queueEntry node, and the other player
    // will listen to changes in queueEntry node
    if(queueEntryIdObs.value==auth.currentUser?.email){
      //stop receiving updates for this queue entry
      queueEntryListener?.cancel();
      fetchQuiz();
    }else{

      //observe to begin match when the questions are loaded
      observeQueueQuestionChanges();


    }


  }



  void fetchQuiz() {


    debugPrint('fetchQuiz');

    var categoryApi;
    var difficultyApi;

    Constants.categoryList.forEach((categoryMap) {
      if(categoryMap['category']==selectedCategory.value){
        categoryApi=categoryMap['api'];
      }
    });

    Constants.difficultyList.forEach((difficultyMap) {
      if(difficultyMap['difficulty']==selectedDifficulty.value){
        difficultyApi=difficultyMap['api'];
      }
    });

    DioHelper.getQuestions(queryParams:  {
      'difficulty': difficultyApi,
      'amount': numOfQuestions.value.toInt(),
      'category': categoryApi,
      'type': 'multiple',
    }).then((jsonResponse) {

      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode==null && apiModel.responseCode!=0) {
        errorLoadingQuestions.value = 'error_loading_quiz'.tr;

        debugPrint('error loading questions from API');

        //todo show error loading questions
      } else {

        uploadQuiz(apiModel.questions);

      }
    }).onError((error, stackTrace) {
      //todo show error loading questions
      debugPrint('error loading questions from API'+error.toString());
      errorLoadingQuestions.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
    });


  }


  void testFetchQuiz() {
    var categoryApi;
    var difficultyApi;

    Constants.categoryList.forEach((categoryMap) {
      if(categoryMap['category']==selectedCategory.value){
        categoryApi=categoryMap['api'];
      }
    });

    Constants.difficultyList.forEach((difficultyMap) {
      if(difficultyMap['difficulty']==selectedDifficulty.value){
        difficultyApi=difficultyMap['api'];
      }
    });

    DioHelper.getQuestions(queryParams:  {
      'difficulty': difficultyApi,
      'amount': numOfQuestions.value.toInt(),
      'category': categoryApi,
      'type': 'multiple',
    }).then((jsonResponse) {

      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode==null && apiModel.responseCode!=0) {
        errorLoadingQuestions.value = 'error_loading_quiz'.tr;
        debugPrint('error loading questions from API');
      } else {


      }
    }).onError((error, stackTrace) {
      debugPrint('error loading questions from API'+error.toString());
      errorLoadingQuestions.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
    });


  }

  void uploadQuiz(questions) {
    debugPrint('uploadQuiz');

    var questionsJson=[];
    questions.forEach((question){
      questionsJson.add(questionModelToJson(question));
    });
      //upload quiz to firestore
      queueCollection
          .doc(queueEntryIdObs.value)
          .update({'questions':questionsJson })
          .then((value) {

        queueCollection
            .doc(queueEntryIdObs.value).get().then((value) {
          Get.to(()=> VersusRandomQuizScreen(),arguments: QueueEntryModel.fromJson(value.data()));
        }).onError((error, stackTrace) {
          debugPrint('firestore get new after add questions error : ' + error.toString());
        });


      }).onError((error, stackTrace) {
        downloadState.value = DownloadState.ERROR;
        debugPrint('firestore add questions error : ' + error.toString());
      });


  }

  void observeQueueQuestionChanges() {

    StreamSubscription streamSubscription=queueCollection
        .doc(queueEntryIdObs.value)
        .snapshots()
        .listen((queueEntryJson) {
      debugPrint('observeQueueQuestionChanges success :' + queueEntryJson.data().toString());
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.questions.isNotEmpty) {
        Get.to(()=> VersusRandomQuizScreen(),arguments: queueEntry);
      }
    });

    streamSubscription.onError((error, stackTrace) {
      errorLoadingQuestions.value = (error.toString());
      downloadState.value = DownloadState.ERROR;
      debugPrint('observeQueueQuestionChanges error :' + error.toString());
    });

  }




}
