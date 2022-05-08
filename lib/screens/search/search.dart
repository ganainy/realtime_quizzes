import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/screens/friends/friends_controller.dart';
import 'package:realtime_quizzes/screens/search/search_controller.dart';

import '../../customization/theme.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  TextEditingController searchTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final SearchController searchController = Get.put(SearchController());
  final FriendsController friendsController = Get.find<FriendsController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Scaffold(
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                DefaultFormField(
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Search',
                    controller: searchTextEditingController,
                    suffixIcon: IconButton(
                        onPressed: () {
                          searchController
                              .findUser(searchTextEditingController.value.text);
                        },
                        icon: const Icon(Icons.search))),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: searchController.downloadState.value ==
                              DownloadState.LOADING
                          ? CircularProgressIndicator()
                          : searchController.downloadState.value ==
                                  DownloadState.INITIAL
                              ? Text(
                                  'Find a user by his email address',
                                  style: Theme.of(context).textTheme.headline2,
                                )
                              : searchController.downloadState.value ==
                                      DownloadState.ERROR
                                  ? Text(
                                      '${searchController.errorObs.value}',
                                      style:
                                          Theme.of(context).textTheme.headline2,
                                    )
                                  : SizedBox(
                                      height: 180,
                                      child: Card(
                                        color: lightCardColor,
                                        child: Column(
                                          children: [
                                            DefaultStatusImage(
                                                isOnline: searchController
                                                    .userObs.value?.isOnline,
                                                imageUrl: searchController
                                                    .userObs.value?.imageUrl),
                                            Text(
                                                '${searchController.userObs.value?.name}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1),
                                            searchController
                                                    .sentFriendRequestObs.value
                                                ? DefaultIconButton(
                                                    text: 'Sent friend request',
                                                    onPressed: () {},
                                                    icon: null,
                                                  )
                                                : DefaultIconButton(
                                                    text: 'Add friend',
                                                    onPressed: () {
                                                      searchController
                                                          .sendFriendRequest(
                                                              searchController
                                                                  .userObs
                                                                  .value);
                                                    },
                                                    icon: Icons.group_add,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }
}
