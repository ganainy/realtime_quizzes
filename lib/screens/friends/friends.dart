import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/models/player.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';
import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.put(FriendsController());
  MainController mainController = Get.find<MainController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Center(
        child: Column(
          children: [
            GameInvites(context),
            const SizedBox(
              height: largePadding,
            ),
            Friends(context),
            const SizedBox(
              height: largePadding,
            ),
            FriendSuggestions(context),
            const SizedBox(
              height: largePadding,
            ),
            IncomingFriendRequests(context),
          ],
        ),
      )),
    );
  }

  GameInvites(BuildContext context) {
    return Obx(() {
      return mainController.receivedInvitesObs.value.isEmpty
          ? const SizedBox()
          : Column(
              children: [
                Text('Game invites',
                    style: Theme.of(context).textTheme.headline1),
                const SizedBox(
                  height: 20,
                ),
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
                          return Card(
                            color: cardColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      (2 / 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      DefaultStatusImage(
                                          imageUrl: otherPlayer.imageUrl,
                                          isOnline: otherPlayer.isOnline),
                                      Spacer(),
                                      IconButton(
                                          onPressed: () {
                                            mainController.acceptGameInvite(
                                                incomingGameInvite);
                                          },
                                          icon: Image.asset(
                                            'assets/images/accept.png',
                                            width: 30,
                                            height: 30,
                                            color: Colors.green,
                                          )),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/images/decline.png',
                                          width: 20,
                                          height: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          mainController.declineGameInvite(
                                              incomingGameInvite);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      (2 / 3),
                                  child: ExpansionTile(
                                    title: const Text('Specs'),
                                    children: [
                                      Text(
                                        'From: ${otherPlayer.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        'Difficulty: ${incomingGameInvite.difficulty}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        'Category: ${incomingGameInvite.category}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        'Number of question: ${incomingGameInvite.numberOfQuestions}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ],
                                  ),
                                )
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
  FriendSuggestions(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text('Friend suggestions',
              style: Theme.of(context).textTheme.headline1),
          SizedBox(
            height: 20,
          ),
          friendsController.friendSuggestionsObs.value.isEmpty
              ? Text('No friend suggestions currently')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return friendsController
                            .friendSuggestionsObs.value.isNotEmpty
                        ? Row(
                            children: [
                              ...friendsController.friendSuggestionsObs.value
                                  .map((friendSuggestion) => Card(
                                        color: lightCardColor,
                                        child: Column(
                                          children: [
                                            DefaultStatusImage(
                                                isOnline:
                                                    friendSuggestion.isOnline,
                                                imageUrl:
                                                    friendSuggestion.imageUrl),
                                            Text('${friendSuggestion.name}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1),
                                            DefaultIconButton(
                                              text: 'Add friend',
                                              onPressed: () {
                                                friendsController
                                                    .sendFriendRequest(
                                                        friendSuggestion);
                                              },
                                              icon: Icons.group_add,
                                            ),
                                          ],
                                        ),
                                      ))
                            ],
                          )
                        : Text('No more friend suggestions available');
                  }),
                ),
        ],
      );
    });
  }

  Friends(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text(
            'Friends',
            style: Theme.of(context).textTheme.headline1,
          ),
          SizedBox(
            height: 20,
          ),
          friendsController.friendsObs.value.isEmpty
              ? Text('you have no friends currently')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: [
                        ...friendsController.friendsObs.value
                            .map((friend) => SizedBox(
                                  width: cardWidth,
                                  child: Card(
                                    color: lightCardColor,
                                    child: Column(
                                      children: [
                                        DefaultStatusImage(
                                            imageUrl: friend.imageUrl,
                                            isOnline: friend.isOnline),
                                        Text(
                                          '${friend.name}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        DefaultIconButton(
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
                                            icon: Icons.delete),
                                      ],
                                    ),
                                  ),
                                ))
                      ],
                    );
                  }),
                ),
        ],
      );
    });
  }

  IncomingFriendRequests(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text('Incoming friend requests',
              style: Theme.of(context).textTheme.headline1),
          SizedBox(
            height: 20,
          ),
          friendsController.receivedFriendRequestsObs.value.isEmpty
              ? Text('No friend requests currently')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return friendsController
                            .receivedFriendRequestsObs.value.isNotEmpty
                        ? Row(
                            children: [
                              ...friendsController
                                  .receivedFriendRequestsObs.value
                                  .map((incomingFriendRequest) => Card(
                                        color: lightCardColor,
                                        child: Column(
                                          children: [
                                            DefaultStatusImage(
                                                imageUrl: incomingFriendRequest
                                                    .imageUrl,
                                                isOnline: incomingFriendRequest
                                                    .isOnline),
                                            Text(
                                              ' ${incomingFriendRequest.name}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                            DefaultIconButton(
                                                text: 'accept',
                                                onPressed: () {
                                                  friendsController
                                                      .acceptFriendRequest(
                                                          incomingFriendRequest);
                                                },
                                                icon: Icons.add),
                                          ],
                                        ),
                                      ))
                            ],
                          )
                        : Text('No more friend suggestions available');
                  }),
                ),
        ],
      );
    });
  }
}
