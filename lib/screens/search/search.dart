import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/screens/friends/friends_controller.dart';
import 'package:realtime_quizzes/screens/search/search_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../customization/theme.dart';
import '../../models/user.dart';
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
                          searchController.searchQuery.value =
                              searchTextEditingController.value.text;
                          searchController.findUserMatches();
                        },
                        icon: const Icon(Icons.search))),
                Expanded(
                  child: searchController.downloadState.value ==
                          DownloadState.LOADING
                      ? ShimmerLoading()
                      : searchController.downloadState.value ==
                              DownloadState.INITIAL
                          ? Text(
                              'Find a user by his name or email address',
                              style: Theme.of(context).textTheme.headline2,
                            )
                          : searchController.downloadState.value ==
                                  DownloadState.EMPTY
                              ? Text(
                                  'No matches found',
                                  style: Theme.of(context).textTheme.headline2,
                                )
                              : QueryResults(),
                ),
              ],
            ),
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }

  QueryResults() {
    return ListView.separated(
        itemBuilder: (context, index) {
          var currentUser = searchController.results.value.elementAt(index);
          return SizedBox(
            child: GradientContainer(
              child: Row(
                children: [
                  DefaultCircularNetworkImage(imageUrl: currentUser.imageUrl),
                  Expanded(
                    child: Text(
                      '${currentUser.name} ',
                      style: Theme.of(context).textTheme.subtitle1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InteractButton(currentUser: currentUser),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox();
        },
        itemCount: searchController.results.value.length);
  }

  //this button text and image changes based on the current result's status
  InteractButton({UserModel? currentUser}) {
    var text;

    switch (currentUser?.userStatus) {
      case UserStatus.NOT_FRIEND:
        text = 'Add';
        break;
      case UserStatus.FRIEND:
        text = 'Friend';
        break;
      case UserStatus.SENT_FRIEND_REQUEST:
        text = 'Accept request';
        break;
      case UserStatus.RECEIVED_FRIEND_REQUEST:
        text = 'Already sent request';
        break;
      default:
        Exception('Unknown user status');
        break;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(smallPadding),
        color: cardColor,
      ),
      child: TextButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          searchController.interactWithUser(currentUser);
        },
      ),
    );
  }

  ShimmerLoading() {
    //todo test shimmer
    return ListView.separated(
        itemBuilder: (context, index) {
          return SizedBox(
            child: GradientContainer(
              child: Row(
                children: [
                  ShimmerWrapper(
                      child: DefaultCircularNetworkImage(imageUrl: '')),
                  Expanded(
                    child: ShimmerWrapper(child: const Text('')),
                  ),
                  ShimmerWrapper(child: InteractButton()),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox();
        },
        itemCount: searchController.results.value.length);
  }

  ShimmerWrapper({required child}) {
    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: cardColor,
        highlightColor: lighterCardColor,
        child: child,
      ),
    );
  }
}
