import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../models/game.dart';
import '../../shared/components.dart';
import '../games/games_controller.dart';
import '../search/search.dart';
import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.find<FriendsController>();
  MainController mainController = Get.find<MainController>();
  GamesController gamesController = Get.find<GamesController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: smallPadding,
            ),
            friendsController.loggedUserGameObs.value != null
                ? LoggedUserGameView(
                    context, friendsController.loggedUserGameObs.value)
                : const SizedBox(),
            const SizedBox(
              height: smallPadding,
            ),
            friendsController.receivedFriendRequestsObs.value.isNotEmpty
                ? ReceivedFriendRequestsView(
                    context, friendsController.receivedFriendRequestsObs.value)
                : const SizedBox(),
            const SizedBox(
              height: smallPadding,
            ),
            FriendsView(context, friendsController.friendsObs.value),
          ],
        );
      }),
    );
  }

  Widget LoggedUserGameView(BuildContext context, GameModel? availableGame) {
    return CircleBorderContainer(
      child: Column(
        children: [
          Row(
            children: [
              CustomChip(label: '${availableGame?.gameSettings?.difficulty}'),
              CustomChip(label: '${availableGame?.gameSettings?.category}'),
              CustomChip(
                  label:
                      '${availableGame?.gameSettings?.numberOfQuestions?.toInt()} Questions'),
              const Expanded(child: SizedBox()),
              IconButton(
                iconSize: 30,
                icon: const Icon(Icons.cancel),
                color: darkText,
                onPressed: () {
                  mainController.deleteLoggedUserGame();
                  friendsController.loggedUserGameObs.value = null;
                },
              ),
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
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget FriendsView(BuildContext context, friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(start: smallPadding),
          child: Text(
            'Friends',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(
          height: smallPadding,
        ),
        friendsController.friendsObs.value.isEmpty
            ? Container(
                margin: const EdgeInsetsDirectional.only(start: smallPadding),
                child: Text(
                  'No friends yet, find new friends using search screen!',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              )
            : SizedBox(
                height: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: smallPadding,
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => SearchScreen());
                          },
                          child: const CircleAvatar(
                            radius: 35,
                            child: const Icon(Icons.add, size: 50),
                          ),
                        ),
                        SizedBox(height: smallPadding),
                        Text(
                          'Discover',
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                      ],
                    ),
                    const SizedBox(
                      width: smallPadding,
                    ),
                    ListView.builder(
                      itemBuilder: (context, index) {
                        var friend = friends.elementAt(index);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              child: DefaultStatusImage(
                                  imageUrl: friend.imageUrl,
                                  isOnline: friend.isOnline),
                              onTap: () {
                                mainController.showFriendDialog(friend);
                              },
                            ),
                            SizedBox(height: 2),
                            SizedBox(
                              width: 70,
                              child: Text(
                                '${friend.name}',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: friends.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  ReceivedFriendRequestsView(BuildContext context, receivedFriendRequests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsetsDirectional.only(start: smallPadding),
          child: Text(
            'Incoming Friend Requests',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            var incomingFriendRequest = receivedFriendRequests.elementAt(index);

            return CircleBorderContainer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultCircularNetworkImage(
                    imageUrl: incomingFriendRequest.imageUrl,
                  ),
                  const SizedBox(width: smallPadding),
                  Expanded(
                    child: Text(
                      '${incomingFriendRequest.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: darkText),
                    ),
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          mainController
                              .acceptFriendRequest(incomingFriendRequest);
                        },
                        child: Card(
                            elevation: 2,
                            child: Container(
                                margin: const EdgeInsets.all(smallPadding),
                                child: Text(
                                  'ACCEPT',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(color: whiteText),
                                )),
                            color: darkBg),
                      ),
                      InkWell(
                        onTap: () {
                          mainController
                              .removeFriendRequest(incomingFriendRequest);
                        },
                        child: Card(
                            elevation: 2,
                            child: Container(
                                margin: const EdgeInsets.all(smallPadding),
                                child: Text(
                                  'REMOVE',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(color: whiteText),
                                )),
                            color: darkBg),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
          itemCount: receivedFriendRequests.length,
          shrinkWrap: true,
        ),
      ],
    );
  }
}
