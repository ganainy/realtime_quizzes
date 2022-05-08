import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';

import '../../main_controller.dart';
import '../../models/api.dart';
import '../../models/queue_entry.dart';
import '../../shared/shared.dart';

class FindGameController extends GetxController {
  var queueEntryModelObs = Rxn<QueueEntryModel>();
  StreamSubscription? observeQueueQuestionChangesStreamSubscription;

  late MainController mainController;

  @override
  void onInit() {
    super.onInit();
    mainController = Get.find<MainController>();
  }

  void enterQueue(BuildContext context) {
    Shared.queueEntryModel.queueEntryId = Shared.loggedUser?.email;
    var players = [PlayerModel(user: Shared.loggedUser)];
    var queueEntryModel = QueueEntryModel(
      inviteStatus: InviteStatus.OPEN_INVITE,
      quizSettings: QuizSettings(
          difficulty:
              mainController.queueEntryObs.value?.quizSettings?.difficulty,
          category: mainController.queueEntryObs.value?.quizSettings?.category,
          numberOfQuestions: mainController
              .queueEntryObs.value?.quizSettings?.numberOfQuestions,
          createdAt: DateTime.now().millisecondsSinceEpoch),
      queueEntryId: Shared.loggedUser?.email,
      players: players,
    );

    var queueEntryModelJson = queueEntryModelToJson(queueEntryModel);

    queueCollection
        .doc(queueEntryModel.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      debugPrint('scenario 2: created queue entry and in queue');
      mainController.inQueueDialog();
      mainController.observeQueueChanges(context);
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(
          info: 'scenario 2: create queue entry error :' + error.toString());
    });
  }

  //this method will be triggered if this player is matched with another player
  void searchAvailableQueues(BuildContext context) {
    mainController.loadingDialog(
        loadingMessage: 'Looking for games online',
        onCancel: mainController.cancelQueue);
    //todo composite index
    //first try to find alreay existing matching queue entry
    // .where('numberOfQuestions', isEqualTo: numOfQuestions.value.toInt())
    queueCollection
        .where('queueEntryId', isNotEqualTo: (Shared.loggedUser?.email))
        // .where('difficulty', isEqualTo: ((selectedDifficulty.value)))
        // .where('category', isEqualTo: ((selectedCategory.value)))
        .limit(1)
        .get()
        .then((queueEntrysJson) {
      if (queueEntrysJson.docs.isEmpty) {
        debugPrint('Scenario 1: No matches found => Goto scenario 2');
        //no suitable match found
        enterQueue(context);
      } else {
        //found suitable match, add to list of players
        mainController.fetchQuiz().then((jsonResponse) {
          ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
          if (apiModel.responseCode == null || apiModel.responseCode != 0) {
            mainController.errorDialog('error_loading_quiz'.tr);
            printError(info: 'error loading questions from API');
          } else {
            //quiz is loaded successfully, now upload it to queue entry
            debugPrint('Scenario 1: match found ');
            mainController.foundMatchDialog();
            Shared.queueEntryModel.queueEntryId =
                queueEntrysJson.docs.elementAt(0).id;
            mainController
                .uploadQuiz(
              questions: apiModel.questions,
            )
                .then((value) {
              getGame().then((value) {
                addPlayerToGamePlayers(context, value).then((value) {
                  mainController.startGame();
                  debugPrint(
                      'Scenario 1: add player to game players now start match');
                }).catchError((error) {
                  mainController.errorDialog(error.toString());
                  printError(
                      info: 'Scenario 1: startGame error :' + error.toString());
                });
              }).catchError((error) {
                mainController.errorDialog(error.toString());
                printError(
                    info: 'Scenario 1:getGame error :' + error.toString());
              });
            }).onError((error, stackTrace) {
              printError(
                  info: 'error loading questions from API' + error.toString());
              mainController.errorDialog(error.toString());
            });
          }
        });
      }
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(
          info: 'Scenario 1: searchAvailableQueues error :' + error.toString());
    });
  }

  Future<DocumentSnapshot> getGame() async {
    return await queueCollection.doc(Shared.queueEntryModel.queueEntryId).get();
  }

  //add the player to the list of players of the found queue entry to begin match
  Future<void> addPlayerToGamePlayers(
      BuildContext context, DocumentSnapshot documentSnapshot) async {
    if (!documentSnapshot.exists) {
      throw Exception("Queue entry does not exist!");
    }

    var _queueEntryModel = QueueEntryModel.fromJson(documentSnapshot.data());

    //this should never happen
    if (_queueEntryModel.players!.length >= 2) {
      print("Scenario 1: game is already full");
      return;
    }

    _queueEntryModel.players?.add(
      PlayerModel(
        user: Shared.loggedUser,
      ),
    );
    queueEntryModelObs.value = _queueEntryModel;

    return await queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update(queueEntryModelToJson(_queueEntryModel));
  }

  /*void observeQueueQuestionChanges() {
    observeQueueQuestionChangesStreamSubscription = queueCollection
        .doc(queueEntryId.value)
        .snapshots()
        .listen((queueEntryJson) {
      if (!queueEntryJson.exists) {
        mainController.errorDialog('Something went wrong');
      }
      debugPrint('observeQueueQuestionChanges success :');
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.questions!.isNotEmpty) {
        debugPrint('queueEntry.questions.isNotEmpty');
        observeQueueQuestionChangesStreamSubscription?.cancel();
        Get.back(); //hide any alert dialogs
        Get.to(() => MultiPlayerQuizScreen(), arguments: queueEntry);
      } else {
        printError(info: 'queueEntry.questions.isEmpty');
      }
    });

    observeQueueQuestionChangesStreamSubscription?.onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(
          info: 'observeQueueQuestionChanges error :' + error.toString());
    });
  }*/

  getCategoryColor(String? category) {
    if (category ==
        mainController.queueEntryObs.value?.quizSettings?.category) {
      return lightCardColor;
    } else {
      return null;
    }
  }
}
