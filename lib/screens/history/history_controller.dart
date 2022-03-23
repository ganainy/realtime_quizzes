import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../../shared/shared.dart';

class HistoryController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var errorLoadingQuestions = Rxn<String>();
  var resultsObs = Rxn<List<dynamic>>();

  loadMatchHistory() {
    usersCollection.doc(auth.currentUser?.email).get().then((json) {
      var user = UserModel.fromJson(json.data());
      resultsObs.value = user.results;
    }).onError((error, stackTrace) {
      printError(info: 'error loading match history' + error.toString());
    });
  }
}
