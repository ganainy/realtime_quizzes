import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/models/player.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';
import '../search/search.dart';
import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.find<FriendsController>();
  MainController mainController = Get.find<MainController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameInvites(context),
          const SizedBox(
            height: largePadding,
          ),
          IncomingFriendRequests(context),
          const SizedBox(
            height: largePadding,
          ),
          Friends(context),
        ],
      )),
    );
  }

  GameInvites(BuildContext context) {
    return Obx(() {
      return mainController.receivedInvitesObs.value.isEmpty
          ? const SizedBox()
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: [
                        ...mainController.receivedInvitesObs.value
                            .map((incomingGameInvite) {
                          var otherPlayer = incomingGameInvite.players
                              .firstWhere((PlayerModel? element) =>
                                  element?.user?.email !=
                                  Shared.loggedUser?.email)
                              .user;
                          return Container(
                            padding: const EdgeInsets.all(smallPadding),
                            margin: const EdgeInsets.all(smallPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(smallPadding),
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  lightCardColor,
                                  lighterCardColor,
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width -
                                      4 * smallPadding,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      DefaultStatusImage(
                                          imageUrl: otherPlayer.imageUrl,
                                          isOnline: otherPlayer.isOnline),
                                      const SizedBox(
                                        width: smallPadding,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                200,
                                        child: Text(
                                          '${otherPlayer.name} sent you game invite.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 30,
                                        icon: const Icon(Icons.cancel),
                                        color: primaryTextColor,
                                        onPressed: () {
                                          mainController.declineGameInvite(
                                              incomingGameInvite);
                                        },
                                      ),
                                      ...[
                                        'Difficulty: ' +
                                            incomingGameInvite.difficulty
                                                .toString(),
                                        'Category: ' +
                                            incomingGameInvite.category
                                                .toString(),
                                        'Questions: ' +
                                            incomingGameInvite.numberOfQuestions
                                                .toString()
                                      ].map((text) {
                                        return Card(
                                            elevation: 2,
                                            child: Container(
                                                margin: const EdgeInsets.all(
                                                    smallPadding),
                                                child: Text(
                                                  '${text}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2
                                                      ?.copyWith(
                                                          color:
                                                              primaryTextColor),
                                                )),
                                            color: lighterCardColor);
                                      }),
                                      const SizedBox(
                                        height: smallPadding,
                                        width: double.infinity,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          mainController.acceptGameInvite(
                                              incomingGameInvite);
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              6 * smallPadding,
                                          child: Card(
                                              elevation: 5,
                                              child: Container(
                                                  margin: const EdgeInsets.all(
                                                      smallPadding),
                                                  child: Text(
                                                    'ACCEPT',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                primaryTextColor),
                                                  )),
                                              color: lightCardColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      ],
                    );
                  }),
                ),
              ],
            );
    });
  }

  /**/

  Friends(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...friendsController.friendsObs.value.map((friend) => SizedBox(
                  width: cardWidth,
                  child: Column(
                    children: [
                      InkWell(
                        child: DefaultStatusImage(
                            imageUrl: friend.imageUrl,
                            isOnline: friend.isOnline),
                        onTap: () {
                          mainController.showFriendDialog(friend);
                        },
                      ),
                      Text(
                        '${friend.name}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      /* DefaultIconButton(
                                      text: 'challenge',
                                      onPressed: () {
                                        mainController
                                            .showQuizSpecDialog(friend);
                                      },
                                      icon: Icons.wine_bar),
                                  DefaultIconButton(
                                      text: 'remove',
                                      onPressed: () {
                                        friendsController
                                            .deleteFriend(friend);
                                      },
                                      icon: Icons.delete),*/
                    ],
                  ),
                )),
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
            )
          ],
        );
      }),
    );
  }

  IncomingFriendRequests(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            return Row(
              children: [
                ...friendsController.receivedFriendRequestsObs.value
                    .map((incomingFriendRequest) => Container(
                          padding: const EdgeInsets.all(smallPadding),
                          margin: const EdgeInsets.all(smallPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(smallPadding),
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                lightCardColor,
                                lighterCardColor,
                              ],
                            ),
                          ),
                          width: MediaQuery.of(context).size.width -
                              smallPadding * 2,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              DefaultCircularNetworkImage(
                                imageUrl: incomingFriendRequest.imageUrl,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 130,
                                child: Text(
                                  ' ${incomingFriendRequest.name} sent you a friend request',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  friendsController.acceptFriendRequest(
                                      incomingFriendRequest);
                                },
                                child: Card(
                                    elevation: 2,
                                    child: Container(
                                        margin:
                                            const EdgeInsets.all(smallPadding),
                                        child: Text(
                                          'ACCEPT',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              ?.copyWith(
                                                  color: primaryTextColor),
                                        )),
                                    color: lightCardColor),
                              ),
                              InkWell(
                                onTap: () {
                                  friendsController.removeFriendRequest(
                                      incomingFriendRequest);
                                },
                                child: Card(
                                    elevation: 2,
                                    child: Container(
                                        margin:
                                            const EdgeInsets.all(smallPadding),
                                        child: Text(
                                          'REMOVE',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              ?.copyWith(
                                                  color: primaryTextColor),
                                        )),
                                    color: lightCardColor),
                              ),
                            ],
                          ),
                        ))
              ],
            );
          }),
        ),
      ],
    );
  }
}
