import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../../shared/shared.dart';

class ProfileController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var errorLoadingQuestions = Rxn<String>();
  var multiPlayerResultsObs = Rxn<List<dynamic>>();
  var singlePlayerResultsObs = Rxn<List<dynamic>>();
  var userObs = Rxn<UserModel>();

  @override
  void onInit() {
    loadMatchHistory();
    loadUserProfile();
  }

  loadMatchHistory() {
    usersCollection.doc(auth.currentUser?.email).get().then((json) {
      multiPlayerResultsObs.value = [];
      singlePlayerResultsObs.value = [];
      var user = UserModel.fromJson(json.data());
      user.results.forEach((result) {
        result.isMultiPlayer ??= false;
        if (result.isMultiPlayer) {
          multiPlayerResultsObs.value?.add(result);
        } else {
          singlePlayerResultsObs.value?.add(result);
        }
      });
    }).onError((error, stackTrace) {
      printError(info: 'error loading match profile' + error.toString());
    });
  }

  void loadUserProfile() {
    usersCollection.doc(auth.currentUser?.email).get().then((json) {
      var user = UserModel.fromJson(json.data());
      userObs.value = user;
    }).onError((error, stackTrace) {
      printError(info: 'error loading match profile' + error.toString());
    });
  }
}
