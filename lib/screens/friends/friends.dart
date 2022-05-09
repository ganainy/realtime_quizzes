import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      ),
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
                          return GradientContainer(
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
    return Obx(() {
      return friendsController.friendsObs.value.isNotEmpty
          ? Row(
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
                      var friend = friendsController.friendsObs.value[index];
                      return Column(
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
                        ],
                      );
                    },
                    itemCount: friendsController.friendsObs.value.length,
                    shrinkWrap: true,
                  ),
                ),
              ],
            )
          : Container(
              margin: const EdgeInsets.all(largePadding),
              child: Column(
                children: [
                  Text(
                    'No friends yet',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SvgPicture.asset('assets/images/empty.svg',
                      semanticsLabel: 'Empty',
                      height: MediaQuery.of(context).size.height * 0.5),
                  InkWell(
                    onTap: () {
                      Get.to(() => SearchScreen());
                    },
                    child: Card(
                        elevation: 2,
                        child: Container(
                            margin: const EdgeInsets.all(smallPadding),
                            child: Text(
                              'Add friends',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(color: primaryTextColor),
                            )),
                        color: lightCardColor),
                  )
                ],
              ),
            );
    });
  }

  IncomingFriendRequests(BuildContext context) {
    return mainController.receivedFriendRequestsObs.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(start: smallPadding),
                child: Text(
                  'Incoming Friend Requests',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Obx(() {
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var incomingFriendRequest =
                        mainController.receivedFriendRequestsObs.value[index];

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
                          )
                        ],
                      ),
                    );
                  },
                  itemCount:
                      mainController.receivedFriendRequestsObs.value.length,
                  shrinkWrap: true,
                );
              }),
            ],
          )
        : const SizedBox();
  }
}
