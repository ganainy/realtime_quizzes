import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/models/game.dart';
import 'package:realtime_quizzes/screens/games/games_controller.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../models/download_state.dart';
import '../../models/user.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';
import '../crate_game/create_game.dart';

class GamesScreen extends StatelessWidget {
  GamesScreen({Key? key}) : super(key: key);

  final GamesController gamesController = Get.put(GamesController());
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Scaffold(
          body: Column(
            children: [
              const SizedBox(
                height: smallPadding,
              ),
              const SizedBox(
                height: largePadding,
              ),
              gamesController.downloadStateObs.value == DownloadState.LOADING
                  ? LoadingView()
                  : gamesController.downloadStateObs.value ==
                          DownloadState.EMPTY
                      ? EmptyView(context)
                      : gamesController.downloadStateObs.value ==
                              DownloadState.ERROR
                          ? ErrorView(context)
                          : AvailableGamesView(context: context),
              DefaultButton(
                  text: 'Create game',
                  onPressed: (() {
                    Get.to(() => CreateGameScreen());
                  })),
            ],
          ),

          // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }

  Widget AvailableGamesView({required BuildContext context}) {
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          GameModel? availableGame =
              gamesController.availableGamesObs.value.elementAt(index);
          UserModel? availableGameCreator = availableGame?.players
              ?.firstWhere(
                  (player) => player?.user?.email == availableGame.gameId)
              ?.user;

          return availableGameCreator?.email != Shared.loggedUser?.email
              ? AvailableGameByOthersView(
                  availableGameCreator, context, availableGame)
              : LoggedUserGameView(
                  availableGameCreator, context, availableGame);
        },
        itemCount: gamesController.availableGamesObs.value.length,
      ),
    );
  }

  Widget LoggedUserGameView(UserModel? availableGameCreator,
      BuildContext context, GameModel? availableGame) {
    return GradientContainer(
      child: Column(
        children: [
          Row(
            children: [
              ...[
                '${availableGame?.gameSettings?.difficulty}',
                '${availableGame?.gameSettings?.category}',
                '${availableGame?.gameSettings?.numberOfQuestions?.toInt()} Questions',
              ].map((text) {
                return CustomChip(label: text);
              }),
              const Expanded(child: SizedBox()),
              CustomChip(
                  label: 'x',
                  color: secondaryTextColor,
                  onTap: () {
                    mainController.deleteLoggedUserGame();
                  }),
            ],
          ),
          Row(
            children: [
              const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator()),
              const SizedBox(
                width: smallPadding,
              ),
              Expanded(
                child: Text(
                  'Your game is available to other players and will start automatically once opponent joins',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget AvailableGameByOthersView(UserModel? availableGameCreator,
      BuildContext context, GameModel? availableGame) {
    return GradientContainer(
      child: Column(
        children: [
          Row(
            children: [
              DefaultCircularNetworkImage(
                imageUrl: availableGameCreator?.imageUrl,
              ),
              const SizedBox(
                width: smallPadding,
              ),
              Expanded(
                child: Text(
                  '${availableGameCreator?.name}',
                  style: Theme.of(context).textTheme.headline2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: smallPadding,
              ),
              Text(
                '${formatTimeAgo(availableGame?.gameSettings?.createdAt)}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          ),
          Row(
            children: [
              ...[
                '${availableGame?.gameSettings?.difficulty}',
                '${availableGame?.gameSettings?.category}',
                '${availableGame?.gameSettings?.numberOfQuestions?.toInt() ?? 10} Questions',
              ].map((text) {
                return CustomChip(label: text);
              }),
            ],
          ),
          const SizedBox(
            height: smallPadding,
            width: double.infinity,
          ),
          InkWell(
            onTap: () {
              mainController.joinGame(availableGame);
              /* mainController.updateGameInvite(receivedGameInvite!,
                          InviteStatus.FRIEND_ACCEPTED_INVITE);*/
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 6 * smallPadding,
              child: Card(
                  elevation: 5,
                  child: Container(
                      margin: const EdgeInsets.all(smallPadding),
                      child: Text(
                        'Join game',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor),
                      )),
                  color: lightCardColor),
            ),
          ),
        ],
      ),
    );
  }

  LoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  EmptyView(BuildContext context) {
    return Center(
      child: Text(
        'No games available',
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }

  ErrorView(BuildContext context) {
    return Center(
      child: Text(
        'Something went wrong.',
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }
}
