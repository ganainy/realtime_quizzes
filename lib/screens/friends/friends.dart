import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/models/player.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../models/queue_entry.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';
import '../search/search.dart';
import 'friends_controller.dart';

class FriendsScreen extends StatelessWidget {
  FriendsScreen({Key? key}) : super(key: key);

  FriendsController friendsController = Get.find<FriendsController>();
  MainController mainController = Get.find<MainController>();

//todo fix no update ui after add ,remove ,accept request ,send invite
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mainController.receivedGameInvitesObs.value.isNotEmpty
                ? GameInvitesView(
                    context, mainController.receivedGameInvitesObs.value)
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
            friendsController.friendsObs.value.isNotEmpty
                ? FriendsView(context, friendsController.friendsObs.value)
                : NoFriendsView(context),
          ],
        );
      }),
    );
  }

  Widget GameInvitesView(BuildContext context, receivedGameInvites) {
    return ListView.builder(
      itemBuilder: (context, index) {
        QueueEntryModel? receivedGameInvite =
            receivedGameInvites.elementAt(index);
        var otherPlayer = receivedGameInvite?.players
            ?.firstWhere((PlayerModel? element) =>
                element?.user?.email != Shared.loggedUser?.email)
            ?.user;

        return GradientContainer(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 4 * smallPadding,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DefaultStatusImage(
                        imageUrl: otherPlayer?.imageUrl,
                        isOnline: otherPlayer?.isOnline),
                    const SizedBox(
                      width: smallPadding,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 200,
                      child: Text(
                        '${otherPlayer?.name} sent you game invite.',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: const Icon(Icons.cancel),
                      color: primaryTextColor,
                      onPressed: () {
                        mainController.declineGameInvite(receivedGameInvite!);
                      },
                    ),
                    ...[
                      'Difficulty: ${receivedGameInvite?.quizSettings?.difficulty}'
                      //todo add chips
                      // 'Category: ' +
                      //     receivedGameInvite?.category.toString(),
                      // 'Questions: ' +
                      //     receivedGameInvite?.numberOfQuestions
                      //         .toString()
                    ].map((text) {
                      return Card(
                          elevation: 2,
                          child: Container(
                              margin: const EdgeInsets.all(smallPadding),
                              child: Text(
                                '${text}',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(color: primaryTextColor),
                              )),
                          color: lighterCardColor);
                    }),
                    const SizedBox(
                      height: smallPadding,
                      width: double.infinity,
                    ),
                    InkWell(
                      onTap: () {
                        mainController.acceptGameInvite(receivedGameInvite!);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width -
                            6 * smallPadding,
                        child: Card(
                            elevation: 5,
                            child: Container(
                                margin: const EdgeInsets.all(smallPadding),
                                child: Text(
                                  'ACCEPT',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: primaryTextColor),
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
      },
      itemCount: receivedGameInvites.length,
      scrollDirection: Axis.horizontal,
    );
  }

  Widget FriendsView(BuildContext context, friends) {
    return Row(
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
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              var friend = friends.elementAt(index);
              return Column(
                children: [
                  InkWell(
                    child: DefaultStatusImage(
                        imageUrl: friend.imageUrl, isOnline: friend.isOnline),
                    onTap: () {
                      mainController.showFriendDialog(friend);
                    },
                  ),
                  Text(
                    '${friend.name}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              );
            },
            itemCount: friends.length,
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }

  Widget NoFriendsView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(largePadding),
      child: Text(
        'No friends yet, visit discover page to add some!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline2,
      ),
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

            return GradientContainer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultCircularNetworkImage(
                    imageUrl: incomingFriendRequest.imageUrl,
                  ),
                  Expanded(
                    child: Text(
                      '${incomingFriendRequest.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
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
                                      ?.copyWith(color: primaryTextColor),
                                )),
                            color: lightCardColor),
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
                                      ?.copyWith(color: primaryTextColor),
                                )),
                            color: lightCardColor),
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
