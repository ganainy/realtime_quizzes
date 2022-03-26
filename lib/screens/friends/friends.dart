import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../shared/constants.dart';
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
              height: 100,
            ),
            Friends(context),
            const SizedBox(
              height: 100,
            ),
            FriendSuggestions(context),
            const SizedBox(
              height: 100,
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
                Text('You have game invite',
                    style: Theme.of(context).textTheme.headline4),
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: [
                        ...friendsController.receivedInvitesObs.value
                            .map((incomingGameInvite) => Card(
                                  child: Column(
                                    children: [
                                      Text(
                                          'sender email: ${incomingGameInvite.queueEntryId}'),
                                      Text(
                                          'difficulty: ${incomingGameInvite.difficulty}'),
                                      Text(
                                          'category: ${incomingGameInvite.category}'),
                                      Text(
                                          'number of question: ${incomingGameInvite.numberOfQuestions}'),
                                      TextButton(
                                        child: Text('start game'),
                                        onPressed: () {
                                          friendsController.acceptGameInvite(
                                              incomingGameInvite);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('decline'),
                                        onPressed: () {
                                          friendsController.declineGameInvite(
                                              incomingGameInvite);
                                        },
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
    });
  }

  FriendSuggestions(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text('Friend suggestions',
              style: Theme.of(context).textTheme.headline4),
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
                                        child: Column(
                                          children: [
                                            Text(
                                                'name: ${friendSuggestion.name}'),
                                            Text(
                                                'email: ${friendSuggestion.email}'),
                                            Text(
                                                'isOnline: ${friendSuggestion.isOnline}'),
                                            TextButton(
                                              child:
                                                  Text('Send friend request'),
                                              onPressed: () {
                                                friendsController
                                                    .sendFriendRequest(
                                                        friendSuggestion);
                                              },
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
            style: Theme.of(context).textTheme.headline4,
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
                            .map((friend) => Card(
                                  child: Column(
                                    children: [
                                      Text('name: ${friend.name}'),
                                      Text('email: ${friend.email}'),
                                      friend.isOnline
                                          ? const CircleAvatar(
                                              backgroundColor: Colors.green,
                                              radius: 8,
                                            )
                                          : const CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 8,
                                            ),
                                      friend.isOnline
                                          ? TextButton(
                                              child: Text('send game invite'),
                                              onPressed: () {
                                                showQuizSpecDialog(friend);
                                              },
                                            )
                                          : const SizedBox(),
                                      TextButton(
                                        child: Text('delete from friends'),
                                        onPressed: () {
                                          friendsController
                                              .deleteFriend(friend);
                                        },
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
    });
  }

  IncomingFriendRequests(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text('Incoming friend requests',
              style: Theme.of(context).textTheme.headline4),
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
                                        child: Column(
                                          children: [
                                            Text(
                                                'name: ${incomingFriendRequest.name}'),
                                            Text(
                                                'email: ${incomingFriendRequest.email}'),
                                            Text(
                                                'isOnline: ${incomingFriendRequest.isOnline}'),
                                            TextButton(
                                              child:
                                                  Text('accept friend request'),
                                              onPressed: () {
                                                friendsController
                                                    .acceptFriendRequest(
                                                        incomingFriendRequest);
                                              },
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
