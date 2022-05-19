import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/download_state.dart';
import '../../shared/shared.dart';

class ProfileController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var multiPlayerResultsObs = Rxn<List<dynamic>>(); //list of ResultModel
  var singlePlayerResultsObs = Rxn<List<dynamic>>(); //list of ResultModel

  var multiPlayerWonGamesCount = 0.obs;

  @override
  void onInit() {}

  updateMatchHistory() {
    multiPlayerResultsObs.value = [];
    singlePlayerResultsObs.value = [];

    Shared.loggedUser?.results.forEach((result) {
      result.isMultiPlayer ??= false;
      if (result.isMultiPlayer) {
        multiPlayerResultsObs.value?.add(result);
      } else {
        singlePlayerResultsObs.value?.add(result);
      }
    });

    multiPlayerResultsObs.value?.forEach((result) {
      if (result.type == 'win') {
        multiPlayerWonGamesCount.value = (multiPlayerWonGamesCount.value + 1);
      }
    });
  }
}
