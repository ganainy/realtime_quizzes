import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../customization/theme.dart';
import '../../shared/components.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.put(FriendsController());

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
      return friendsController.receivedInvitesObs.value.isEmpty
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
                        ...friendsController.receivedInvitesObs.value
                            .map((incomingGameInvite) {
                          var otherPlayer = incomingGameInvite.players
                              .firstWhere((element) =>
                                  element?.playerEmail !=
                                  auth.currentUser?.email)
                              .player;
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
                                            friendsController.acceptGameInvite(
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
                                          friendsController.declineGameInvite(
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
                                              showQuizSpecDialog(friend);
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

  void showQuizSpecDialog(friend) {
    Widget startButton = TextButton(
      child: Text("Start"),
      onPressed: () {
        friendsController.fetchQuiz(friend);
        Get.back();
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [startButton, cancelButton],
      title: 'Select game options',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            return ToggleButtons(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.green,
                ),
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.orange,
                ),
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.red,
                ),
              ],
              isSelected: friendsController.difficultySelectionsObs.value,
              onPressed: (int index) {
                switch (index) {
                  case 0:
                    friendsController.difficultySelectionsObs.value[0] = true;
                    friendsController.difficultySelectionsObs.value[1] = false;
                    friendsController.difficultySelectionsObs.value[2] = false;
                    break;
                  case 1:
                    friendsController.difficultySelectionsObs.value[0] = false;
                    friendsController.difficultySelectionsObs.value[1] = true;
                    friendsController.difficultySelectionsObs.value[2] = false;
                    break;
                  case 2:
                    friendsController.difficultySelectionsObs.value[0] = false;
                    friendsController.difficultySelectionsObs.value[1] = false;
                    friendsController.difficultySelectionsObs.value[2] = true;
                    break;
                }
                Get.back();
                showQuizSpecDialog(friend);
              },
            );
          }),
          DropdownButton<String>(
            items: Constants.categoryNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              friendsController.categorySelectionsObs.value = value!;
              debugPrint('$value');
              Get.back();
              showQuizSpecDialog(friend);
            },
            value: friendsController.categorySelectionsObs.value,
          ),
          DropdownButton<String>(
            items: [
              '2',
              '3',
              '4',
              '5',
              '6',
              '7',
              '8',
              '9',
              '10',
              '11',
              '12',
              '13',
              '14',
              '15',
              '16',
              '17',
              '18',
              '19',
              '19',
              '20',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: (value) {
              friendsController.numQuestionsSelectionsObs.value = value;
              debugPrint('$value');
              Get.back();
              showQuizSpecDialog(friend);
            },
            value: friendsController.numQuestionsSelectionsObs.value ?? '10',
          )
        ],

        //  Constants.categoryList.map((category) =>
      ),
    );
  }
}
