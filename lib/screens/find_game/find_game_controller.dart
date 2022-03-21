import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/invite.dart';
import 'package:realtime_quizzes/shared/converters.dart';

import '../../layouts/home/home.dart';
import '../../models/category.dart';
import '../../models/difficulty.dart';
import '../../models/queue_entry.dart';
import '../../models/quiz.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class FindGameController extends GetxController {
  // var timerCounter = Rxn<int>();

  var numOfQuestions = 10.00.obs;
  var selectedCategory = Category('general_knowledge'.tr, 9).obs;
  var selectedDifficulty = Difficulty('medium'.tr, 'medium').obs;
  var downloadState = DownloadState.INITIAL.obs;
  var isInQueue = false.obs;

  var errorLoadingQuestions = Rxn<String>();
  var quizModel = Rxn<QuizModelApi>();

  void enterQueue(BuildContext context) {

    var players=[PlayerModel(playerEmail: auth.currentUser?.email,isReady: true)];
    var queueEntryModel=QueueEntryModel(selectedDifficulty.value,
        selectedCategory.value,numOfQuestions.value.toInt(),auth.currentUser?.email,players);

    var queueEntryModelJson=queueEntryModelToJson(queueEntryModel);


    queueCollection.doc(queueEntryModel.queueEntryId).set(queueEntryModelJson).then((value) {
      downloadState.value=DownloadState.SUCCESS;
      isInQueue.value=true;
      inQueueDialog(context);
      debugPrint('in queue');

      observeQueueChanges( context);
      observeOtherQueues(context);

    }).onError((error, stackTrace) {
      errorLoadingQuestions.value=(error.toString());
      downloadState.value=DownloadState.ERROR;
      debugPrint('enter queue error :'+error.toString());
    });
  }


  inQueueDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        cancelQueue();
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Play offline"),
      onPressed:  () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("In queue"),
      content: Column(crossAxisAlignment:CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children:[Text("Game will start once we find another player with same search paramaters as you"),
          SizedBox(height: 10,),
          CircularProgressIndicator(),], ),
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
      content: Column(crossAxisAlignment:CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children:[Text("Game will start shortly"),
          SizedBox(height: 10,),
          CircularProgressIndicator(),], ),
      actions: [
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

  void cancelQueue() {

    queueCollection.doc(auth.currentUser?.email).delete().then((value) {
      isInQueue.value==false;
      debugPrint('left queue');

    }).onError((error, stackTrace) {
      errorLoadingQuestions.value=(error.toString());
      downloadState.value=DownloadState.ERROR;
      debugPrint('leave queue error :'+error.toString());
    });

  }

  //this method will be triggered if another player is matched with this player
  void observeQueueChanges(BuildContext context) {


    queueCollection.doc(auth.currentUser?.email).snapshots().listen((queueEntryJson) {

      var queueEntry =QueueEntryModel.fromJson(queueEntryJson.data());
      if(queueEntry.players.length>1){
        Get.back();
        foundMatchDialog(context);
        debugPrint('match should start');
      }else{
        debugPrint('still one player: '+queueEntry.players.length.toString());
      }

    }).onError((error, stackTrace) {
      errorLoadingQuestions.value=(error.toString());
      downloadState.value=DownloadState.ERROR;
      debugPrint('observing queue error :'+error.toString());
    });


  }


  //this method will be triggered if this player is matched with another player
  void observeOtherQueues(BuildContext context) {


    queueCollection .where('numberOfQuestions', isEqualTo: numOfQuestions.value.toInt())
        .where('difficulty', isEqualTo:(difficultyModelToJson(selectedDifficulty.value)))
        .where('category', isEqualTo:(categoryModelToJson(selectedCategory.value)))
        .snapshots().listen((queueEntrysJson) {

      queueEntrysJson.docs.forEach((queueEntryJson) {

      var queueEntry =QueueEntryModel.fromJson(queueEntryJson.data());
      if(queueEntry.queueEntryId!=auth.currentUser?.email){
        debugPrint('successful match ${queueEntry.numberOfQuestions}');
      }else{
        debugPrint('cant match with yourself');
      }

      });


    }).onError((error, stackTrace) {
      errorLoadingQuestions.value=(error.toString());
      downloadState.value=DownloadState.ERROR;
      debugPrint('observeOtherQueues error :'+error.toString());
    });


  }


}
