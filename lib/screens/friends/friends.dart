import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.put(FriendsController())
    ..loadFriends()
    ..loadFriendSuggestions()
    ..loadFriendRequests();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Center(
        child: Column(
          children: [
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

  FriendSuggestions(BuildContext context) {
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
                  return friendsController.friendSuggestionsObs.value.isNotEmpty
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
                                            child: Text('Send friend request'),
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
  }

  Friends(BuildContext context) {
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
                                    Text('isOnline: ${friend.isOnline}'),
                                    TextButton(
                                      child: Text('send game invite'),
                                      onPressed: () {
                                        //todo send invite
                                      },
                                    ),
                                    TextButton(
                                      child: Text('delete from friends'),
                                      onPressed: () {
                                        friendsController.deleteFriend(friend);
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
  }

  IncomingFriendRequests(BuildContext context) {
    return Column(
      children: [
        Text('Incoming friend requests',
            style: Theme.of(context).textTheme.headline4),
        SizedBox(
          height: 20,
        ),
        friendsController.incomingFriendRequestsObs.value.isEmpty
            ? Text('No friend requests currently')
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() {
                  return friendsController
                          .incomingFriendRequestsObs.value.isNotEmpty
                      ? Row(
                          children: [
                            ...friendsController.incomingFriendRequestsObs.value
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
  }
}
