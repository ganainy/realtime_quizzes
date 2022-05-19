import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/screens/friends/friends_controller.dart';
import 'package:realtime_quizzes/screens/profile/profile_controller.dart';
import 'package:realtime_quizzes/screens/search/search_controller.dart';

import '../../models/game.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../network/dio_helper.dart';
import '../../screens/multiplayer_quiz/multiplayer_quiz_screen.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
import 'customization/theme.dart';
import 'layouts/home/home.dart';
import 'models/Connection.dart';
import 'models/UserStatus.dart';
import 'models/user.dart';

class MainController extends GetxController {
  var isOnlineObs = Rxn<bool>();

  //observables to update ui
  var userObs = Rxn<UserModel?>();
  var gameObs = Rxn<GameModel?>();
  var receivedGameInvitesObs = [].obs; //list of game
  /*Function eq = const ListEquality().equals; //function to compare two lists*/
  StreamSubscription? queueEntryListener;

  late FriendsController friendsController;
  late SearchController searchController;
  late ProfileController profileController;

  bool isDialogOpen = false; //flag to check if dialog is open
  @override
  void onInit() {
    friendsController = Get.put(FriendsController());
    searchController = Get.put(SearchController());
    profileController = Get.put(ProfileController());
    //set user as online on app start
    changeUserStatus(true);
    //set initial values of quiz parameters
    gameObs.value = Shared.game;
    //save latest game setting values in shared class to access through app
    gameObs.listen((p0) {
      Shared.game = p0!;
    });
  }

  /// ******************************* Logged User ****************************/

  //set user status to online or offline
  void changeUserStatus(bool isOnline) {
    //set user as online and offline based on if using app or not
    usersCollection.doc(Shared.loggedUser?.email).update({
      'isOnline': isOnline,
    }).then((value) {
      debugPrint('update status success');
      isOnlineObs.value = isOnline;
    });
  }

  //observe changes of logged user to update the profile
  observeProfileChanges() {
    usersCollection.doc(Shared.loggedUser?.email).snapshots().listen((event) {
      var user = UserModel.fromJson(event.data());
      Shared.loggedUser = user;
      userObs.value = user;

      //load user connection
      friendsController.loadConnections();
      //update state of search results
      searchController.updateQueryResultsState();
      //update stated of user created game (if any)
      updateGameStatus(
          game: Shared.game,
          gameStatus: user.isOnline ? GameStatus.ACTIVE : GameStatus.INACTIVE);
      //update match history
      profileController.updateMatchHistory();
      debugPrint('logged user changed');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'error observe logged user' + error.toString());
    });
  }

  /// ******************************* API ***********************************/
  //load questions from api
  Future<dynamic> fetchQuiz({String? queueEntryId}) async {
    debugPrint('fetchQuiz');

    var categoryApi;
    var difficultyApi;

    //convert category name to match the param thats passed to api
    Constants.categoryList.forEach((categoryMap) {
      if (categoryMap['category'].toString().toLowerCase() ==
          Shared.game.gameSettings?.category?.toLowerCase()) {
        categoryApi = categoryMap['api'];
      }
    });

    //convert difficulty name to match the param thats passed to api
    Constants.difficultyList.forEach((difficultyMap) {
      if (difficultyMap['difficulty'].toString().toLowerCase() ==
          Shared.game.gameSettings?.difficulty?.toLowerCase()) {
        difficultyApi = difficultyMap['api'];
      }
    });

    var params = {
      'difficulty': difficultyApi,
      'amount': Shared.game.gameSettings?.numberOfQuestions?.round() ?? 10,
      'category': categoryApi,
      'type': 'multiple',
    };

    //remove null parameters from queryParams so API call won't fail
    if (params['difficulty'] == null) {
      params.remove('difficulty');
    }
    if (params['category'] == null ||
        params['category'] ==
            'Random'.tr /*this is not real category its just for UI*/) {
      params.remove('category');
    }

    debugPrint('final params: $params');

    return await DioHelper.getQuestions(queryParams: params);
  }

  //upload loaded questions to firebase to be used in multiplayer
  Future<void> uploadQuiz({
    required List<QuestionModel> questions,
  }) async {
    debugPrint('uploadQuiz');

    var questionsJson = [];
    questions.forEach((question) {
      questionsJson.add(questionModelToJson(question));
    });
    //upload quiz to firestore
    return await gameCollection.doc(Shared.game.gameId).update({
      'questions': questionsJson,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    });
  }

  /// ******************************* Game ***********************************/
  //this method will listen for when another player enters logged player game
  //to start game automatically
  void observeAnotherPlayerJoins() {
    queueEntryListener = gameCollection
        .doc(Shared.loggedUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      Shared.game = GameModel.fromJson(queueEntryJson.data());

      if (Shared.game.gameStatus == GameStatus.INVITE_ACCEPTED &&
          Shared.game.players!.length == 2) {
        updateGameStatus(game: Shared.game, gameStatus: GameStatus.INACTIVE);
        opponentJoinedDialog();
        startMultiPlayerGame();
        debugPrint('invite accepted , match should start');
      }

      queueEntryListener?.onError((error, stackTrace) {
        errorDialog(error.toString());
        printError(info: 'observeQueueChanges error :' + error.toString());
      });
    });
  }

  void startMultiPlayerGame() {
    //stop listening to updates of queue
    queueEntryListener?.cancel();
    Get.back(); //hide any alert dialogs
    Get.to(() => MultiPlayerQuizScreen());
  }

  void joinGame(GameModel? incomingGameInvite) {
    incomingGameInvite?.gameStatus = GameStatus.INVITE_ACCEPTED;
    incomingGameInvite?.players?.add(PlayerModel(user: Shared.loggedUser));
    Shared.game = incomingGameInvite!;

    gameCollection
        .doc(Shared.game.gameId)
        .update(gameModelToJson(Shared.game))
        .then((value) {
      startMultiPlayerGame();
      debugPrint('invite accepted ');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'acceptGameInvite error :' + error.toString());
    });
  }

  //delete game from gamesCollection since its over and reset game
  deleteGame(String? gameId) {
    gameCollection.doc(gameId).delete().then((value) {
      debugPrint('removed from gamesCollection');
    }).onError((error, stackTrace) {
      printError(info: 'error remove from gamesCollection');
    });
  }

  //
  void updateGameStatus(
      {required GameModel game, required GameStatus gameStatus}) {
    //scenario 2
    game.gameStatus = gameStatus;
    gameCollection.doc(game.gameId).update(gameModelToJson(game)).then((value) {
      debugPrint('game set as $gameStatus ');
    }).onError((error, stackTrace) {
      printError(info: 'update game status error :' + error.toString());
    });
  }

  //updating only fields inside observable object and not the whole object
  //doesn't trigger rebuild, so we need to do it manually
  void forceUpdateUi() {
    gameObs.refresh();
  }

  void deleteLoggedUserGame() {
    gameCollection.doc(Shared.loggedUser?.email).delete().then((value) {
      //showSnackbar(message: 'Deleted game successfully');
    }).onError((error, stackTrace) {
      printError(info: 'deleteLoggedUserGame error :' + error.toString());
    });
  }

  /// ********************************* Friends ******************************/

  void sendFriendRequest(UserModel? friendSuggestion) {
    //add other user to logged user sent friends requests
    Connection? loggedUserConnection =
        Shared.loggedUser?.connections.firstWhere((connection) {
      return connection?.email == friendSuggestion?.email;
    }, orElse: () => null);
    if (loggedUserConnection != null) {
      //this should never be true
      Shared.loggedUser?.connections.remove(loggedUserConnection);
    }
    Shared.loggedUser?.connections.add(Connection(
        email: friendSuggestion?.email,
        userStatus: UserStatus.SENT_FRIEND_REQUEST));

    usersCollection
        .doc(Shared.loggedUser?.email)
        .set(userModelToJson(Shared.loggedUser))
        .then((value) {
      debugPrint("1 SENT_FRIEND_REQUEST ");
    }).onError((error, stackTrace) {
      printError(info: "1 Failed SENT_FRIEND_REQUEST: $error");
      errorDialog(error.toString());
    });

    //add logged user to other user received friends requests
    Connection? otherUserConnection =
        friendSuggestion?.connections.firstWhere((connection) {
      return connection?.email == Shared.loggedUser?.email;
    }, orElse: () => null);
    if (otherUserConnection != null) {
      //this should never be true
      friendSuggestion?.connections.remove(otherUserConnection);
    }
    friendSuggestion?.connections.add(Connection(
        email: Shared.loggedUser?.email,
        userStatus: UserStatus.RECEIVED_FRIEND_REQUEST));

    usersCollection
        .doc(friendSuggestion?.email)
        .set(userModelToJson(friendSuggestion))
        .then((value) {
      debugPrint("2 RECEIVED_FRIEND_REQUEST ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "2 Failed RECEIVED_FRIEND_REQUEST: $error");
    });
  }

  void acceptFriendRequest(UserModel? incomingFriendRequest) {
    Connection? loggedUserConnection =
        Shared.loggedUser?.connections.firstWhere((connection) {
      return connection?.email == incomingFriendRequest?.email;
    }, orElse: () => null);
    if (loggedUserConnection != null) {
      Shared.loggedUser?.connections.remove(loggedUserConnection);
    }
    Shared.loggedUser?.connections.add(Connection(
        email: incomingFriendRequest?.email, userStatus: UserStatus.FRIEND));

    //add other user to logged user friends
    usersCollection
        .doc(Shared.loggedUser?.email)
        .update(userModelToJson(Shared.loggedUser))
        .then((value) {
      debugPrint("1 FRIEND ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "1 Failed to FRIEND: $error");
    });

    //add logged user to other user friends
    Connection? otherUserConnection =
        incomingFriendRequest?.connections.firstWhere((connection) {
      return connection?.email == Shared.loggedUser?.email;
    }, orElse: () => null);
    if (otherUserConnection != null) {
      incomingFriendRequest?.connections.remove(otherUserConnection);
    }
    incomingFriendRequest?.connections.add(Connection(
        email: Shared.loggedUser?.email, userStatus: UserStatus.FRIEND));

    usersCollection
        .doc(incomingFriendRequest?.email)
        .update(userModelToJson(incomingFriendRequest))
        .then((value) {
      debugPrint("2 FRIEND ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "2 Failed  FRIEND: $error");
    });
  }

  void removeFriendRequest(UserModel incomingFriendRequest) {
    //add other user to logged user removed requests
    Connection? loggedUserConnection =
        Shared.loggedUser?.connections.firstWhere((connection) {
      return connection?.email == incomingFriendRequest.email;
    }, orElse: () => null);
    if (loggedUserConnection != null) {
      //this should never be true
      Shared.loggedUser?.connections.remove(loggedUserConnection);
    }
    Shared.loggedUser?.connections.add(Connection(
        email: incomingFriendRequest.email,
        userStatus: UserStatus.REMOVED_REQUEST));

    usersCollection
        .doc(Shared.loggedUser?.email)
        .update(userModelToJson(Shared.loggedUser))
        .then((value) {
      debugPrint("removeFriendRequest ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "Failed to removeFriendRequest: $error");
    });
  }

  void deleteFriend(UserModel? friend) {
    //remove other user from logged user friends
    Connection? loggedUserConnection =
        Shared.loggedUser?.connections.firstWhere((connection) {
      return connection?.email == friend?.email;
    }, orElse: () => null);

    Shared.loggedUser?.connections.remove(loggedUserConnection);
    debugPrint("connections: ${Shared.loggedUser?.connections.length}");

    usersCollection
        .doc(Shared.loggedUser?.email)
        .set(userModelToJson(Shared.loggedUser))
        .then((value) {
      debugPrint("1 remove friend ");
    }).onError((error, stackTrace) {
      printError(info: "1 Failed remove friend: $error");
      errorDialog(error.toString());
    });

    //remove logged user from other user friends
    Connection? otherUserConnection =
        friend?.connections.firstWhere((connection) {
      return connection?.email == Shared.loggedUser?.email;
    }, orElse: () => null);
    friend?.connections.remove(otherUserConnection);
    usersCollection
        .doc(friend?.email)
        .set(userModelToJson(friend))
        .then((value) {
      debugPrint("2 remove friend ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "2 Failed remove friend: $error");
    });
  }

  /// ******************************** Snack bar *****************************/

  void showSnackbar({String? message, int? duration}) {
    duration ??= 3;
    Get.snackbar('$message', '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: lightBg,
        colorText: darkText,
        duration: Duration(seconds: duration));
  }

  /// ********************************* Dialogs ******************************/

  void showFriendDialog(UserModel? friend) {
    hideOldDialog();
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        hideCurrentDialog();
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete friend"),
      onPressed: () {
        hideCurrentDialog();
        deleteFriend(friend);
      },
    );

    Get.defaultDialog(
      actions: [deleteButton, cancelButton],
      barrierDismissible: false,
      title: 'Select action for ${friend?.name ?? 'Friend'}',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }

  void showInfoDialog({String? title, required String message}) {
    hideOldDialog();
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        hideCurrentDialog();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: title ?? '',
      barrierDismissible: false,
      content: Text(message, style: TextStyle(fontSize: 14)),
    );
  }

  void confirmExitDialog({bool isOnlineGame = false}) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        hideCurrentDialog();
      },
    );
    Widget confirmButton = TextButton(
      child: Text("Confirm"),
      onPressed: () {
        if (isOnlineGame) {
          //in case of online game, set as abandoned to notify other player he is alone
          updateGameStatus(game: Shared.game, gameStatus: GameStatus.ABANDONED);
        }
        hideCurrentDialog();
        Get.offAll(() => HomeScreen());
      },
    );

    Get.defaultDialog(
      actions: [confirmButton, cancelButton],
      title: 'Exit',
      barrierDismissible: false,
      content: const Text('Are you sure you want to exit game?',
          style: TextStyle(fontSize: 14)),
    );
  }

  void opponentJoinedDialog() {
    hideOldDialog();

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        hideCurrentDialog();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: 'Opponent joined',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Game will start shortly", style: TextStyle(fontSize: 14)),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void loadingDialog({required loadingMessage, onCancel}) {
    hideOldDialog();

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        onCancel();
        hideCurrentDialog();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: loadingMessage,
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void errorDialog(String? errorMessage) {
    hideOldDialog();
    errorMessage ?? 'Something went wrong';

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        hideCurrentDialog();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: 'Error',
      barrierDismissible: false,
      content: Text('${errorMessage}', style: const TextStyle(fontSize: 14)),
    );
  }

  void hideOldDialog() {
    if (isDialogOpen) {
      Get.back(); //hide any showing dialog before opening new one
    }
    isDialogOpen = true;
  }

  void hideCurrentDialog() {
    Get.back();
    isDialogOpen = false;
  }
}
