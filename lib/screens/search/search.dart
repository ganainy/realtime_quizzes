import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
            child: SingleChildScrollView(
              child: searchController.downloadState.value ==
                      DownloadState.LOADING
                  ? ShimmerLoadingView(context)
                  : searchController.downloadState.value ==
                          DownloadState.INITIAL
                      ? InitialView(
                          context, 'Find a user by his name or email address')
                      : searchController.downloadState.value ==
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
      searchController.searchQuery.value =
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
          itemCount: searchController.results.value.length,
          shrinkWrap: true,
          primary: false,
        ),
      ],
    );
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
        text = 'Sent request';
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
          '${text}',
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          searchController.interactWithUser(currentUser);
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
              child: GradientContainer(
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
        baseColor: lightCardColor,
        highlightColor: cardColor,
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
          style: Theme.of(context).textTheme.headline2,
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(largePadding),
            child: SvgPicture.asset(
              'assets/images/search.svg',
              semanticsLabel:
                  'Empty', /*height: MediaQuery.of(context).size.height * 0.5*/
            ),
          ),
        ),
      ],
    );
  }
}
