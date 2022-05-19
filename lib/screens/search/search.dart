import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/screens/friends/friends_controller.dart';
import 'package:realtime_quizzes/screens/search/search_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../customization/theme.dart';
import '../../models/UserStatus.dart';
import '../../models/download_state.dart';
import '../../models/user.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  TextEditingController searchTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final SearchController searchController = Get.find<SearchController>();
  final FriendsController friendsController = Get.find<FriendsController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Scaffold(
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: searchController.downloadStateObs.value ==
                      DownloadState.LOADING
                  ? ShimmerLoadingView(context)
                  : searchController.downloadStateObs.value ==
                          DownloadState.INITIAL
                      ? InitialView(
                          context, 'Find a user by his name or email address')
                      : searchController.downloadStateObs.value ==
                              DownloadState.EMPTY
                          ? InitialView(context, 'No matches found')
                          : ResultsView(),
            ),
          ),
        );
      }),
    );
  }

  SearchFormField() {
    return DefaultFormField(
        keyboardType: TextInputType.emailAddress,
        labelText: 'Search',
        controller: searchTextEditingController,
        onFieldSubmitted: (_) {
          search();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some query';
          }
          return null;
        },
        suffixIcon: IconButton(
            onPressed: () {
              search();
            },
            icon: const Icon(Icons.search)));
  }

  void search() {
    if (_formKey.currentState!.validate()) {
      searchController.searchQueryObs.value =
          searchTextEditingController.value.text;
      searchController.findUserMatches();
    }
  }

  ResultsView() {
    return Column(
      children: [
        const SizedBox(
          height: smallPadding,
        ),
        SearchFormField(),
        ListView.separated(
          itemBuilder: (context, index) {
            var currentUser =
                searchController.queryResultsObs.value.elementAt(index);
            return SizedBox(
              child: CircleBorderContainer(
                child: Row(
                  children: [
                    DefaultCircularNetworkImage(imageUrl: currentUser.imageUrl),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(smallPadding),
                        child: Text(
                          '${currentUser.name} ',
                          style: Theme.of(context).textTheme.subtitle1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
          itemCount: searchController.queryResultsObs.value.length,
          shrinkWrap: true,
          primary: false,
        ),
      ],
    );
  }

  //this button text changes based on the current result's connection to logged user
  InteractButton({UserModel? currentUser}) {
    var text;

    var connection = Shared.loggedUser?.connections.firstWhereOrNull(
        (connection) => connection?.email == currentUser?.email);

    var status;
    if (connection == null) {
      status = UserStatus.NOT_FRIEND;
    } else {
      status = connection.userStatus;
    }

    switch (status) {
      case UserStatus.NOT_FRIEND:
        text = 'Add';
        break;
      case UserStatus.FRIEND:
        text = 'Friend';
        break;
      case UserStatus.SENT_FRIEND_REQUEST:
        text = 'Sent request';
        break;
      case UserStatus.RECEIVED_FRIEND_REQUEST:
        text = 'Accept request';
        break;
      case UserStatus.REMOVED_REQUEST:
        text = 'Add';
        break;
      default:
        Exception('Unknown status');
        break;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(smallPadding),
        color: darkBg,
      ),
      child: TextButton(
        child: Text(
          '${text}',
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          searchController.interactWithUser(currentUser, status);
        },
      ),
    );
  }

  ShimmerLoadingView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: smallPadding,
        ),
        SearchFormField(),
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return SizedBox(
              child: CircleBorderContainer(
                child: Row(
                  children: [
                    ShimmerWrapper(
                        child: DefaultCircularNetworkImage(imageUrl: '')),
                    Expanded(
                      child: ShimmerWrapper(
                          child: SizedBox(
                        child: Text('Loading...'),
                      )),
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
          itemCount: 1,
        ),
      ],
    );
  }

  ShimmerWrapper({required child}) {
    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: darkBg,
        highlightColor: darkBg,
        child: child,
      ),
    );
  }

  InitialView(BuildContext context, String msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: smallPadding,
        ),
        SearchFormField(),
        const SizedBox(
          height: largePadding,
        ),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline1,
        ),
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(largePadding),
              child: SvgPicture.asset(
                'assets/images/search.svg',
                semanticsLabel:
                    'Empty', /*height: MediaQuery.of(context).size.height * 0.5*/
              ),
            ),
          ),
        ),
      ],
    );
  }
}
