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
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.add,
              color: bgColor,
            ),
            backgroundColor: darkBg,
            onPressed: () {
              Get.to(() => CreateGameScreen());
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gamesController.downloadStateObs.value == DownloadState.LOADING
                  ? LoadingView()
                  : gamesController.downloadStateObs.value ==
                          DownloadState.EMPTY
                      ? EmptyView(context)
                      : gamesController.downloadStateObs.value ==
                              DownloadState.ERROR
                          ? ErrorView(context)
                          : AvailableGamesView(context: context),
              gamesController.downloadStateObs.value == DownloadState.EMPTY ||
                      gamesController.downloadStateObs.value ==
                          DownloadState.LOADING
                  ? const SizedBox()
                  : HintTextView(),
            ],
          ),

          // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }

  Padding HintTextView() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 24.0),
      child: Card(
        color: Colors.yellow[200],
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text('Hint: Tap on a game to join it.',
              style: TextStyle(color: darkBg, fontSize: 20)),
        ),
      ),
    );
  }

  Widget AvailableGamesView({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends games',
            style:
                Theme.of(context).textTheme.headline1?.copyWith(fontSize: 24),
          ),
          gamesController.friendsGamesObs.value.isEmpty
              ? Text(
                  'No Friends games available',
                  style: Theme.of(context).textTheme.subtitle1,
                )
              : AvailableGamesList(
                  context: context,
                  gamesList: gamesController.friendsGamesObs.value),
          Text(
            'Other games',
            style:
                Theme.of(context).textTheme.headline1?.copyWith(fontSize: 24),
          ),
          gamesController.availableGamesObs.value.isEmpty
              ? Text(
                  'No Other games available',
                  style: Theme.of(context).textTheme.subtitle1,
                )
              : AvailableGamesList(
                  context: context,
                  gamesList: gamesController.availableGamesObs.value),
        ],
      ),
    );
  }

  Widget AvailableGamesList(
      {required BuildContext context, required gamesList}) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return AvailableGameListItem(
            context, index, gamesList.elementAt(index));
      },
      itemCount: gamesList.length,
    );
  }

  Widget AvailableGameListItem(
    BuildContext context,
    int index,
    game,
  ) {
    UserModel? availableGameCreator = game?.players
        ?.firstWhere((player) => player?.user?.email == game.gameId)
        ?.user;

    return AvailableGameByOthersView(availableGameCreator, context, game);
  }

  Widget AvailableGameByOthersView(UserModel? availableGameCreator,
      BuildContext context, GameModel? availableGame) {
    return CircleBorderContainer(
      child: InkWell(
        onTap: () {
          mainController.joinGame(availableGame);
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 6 * smallPadding - 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    width: smallPadding,
                  ),
                  Text(
                    '${formatTimeAgo(availableGame?.gameSettings?.createdAt)}',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: lightText,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
              Wrap(
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
            ],
          ),
        ),
      ),
    );
  }

  LoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  EmptyView(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          'No games available',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  ErrorView(BuildContext context) {
    return Center(
      child: Text(
        'Something went wrong.',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
