import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/main_controller.dart';

import '../../models/result.dart';
import '../../shared/components.dart';
import '../../shared/shared.dart';
import '../login/login.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Obx(() {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      DefaultCircularNetworkImage(
                          imageUrl: Shared.loggedUser?.imageUrl,
                          width: 120.0,
                          height: 120.0),
                      Text(
                        '${Shared.loggedUser?.name.toUpperCase()}',
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Text(
                        '${Shared.loggedUser?.email}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Container(
                        margin: EdgeInsets.all(mediumPadding),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    profileController.multiPlayerResultsObs.value == null &&
                            profileController.singlePlayerResultsObs.value ==
                                null
                        ? const Center(child: CircularProgressIndicator())
                        : Obx(() {
                            return Column(
                              children: [
                                Card(
                                  margin: EdgeInsets.all(smallPadding),
                                  color: lightBg,
                                  child: ExpansionTile(
                                      title: Text(
                                          'my offline games: (Total:${profileController.singlePlayerResultsObs.value?.length} games)'),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              smallPadding),
                                          child: ListView.builder(
                                              itemCount: profileController
                                                  .singlePlayerResultsObs
                                                  .value
                                                  ?.length,
                                              shrinkWrap: true,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return GameCard(
                                                    profileController
                                                        .singlePlayerResultsObs
                                                        .value!
                                                        .elementAt(index),
                                                    context);
                                              }),
                                        ),
                                      ]),
                                ),
                                SizedBox(
                                  height: smallPadding,
                                ),
                                Card(
                                  margin: EdgeInsets.all(smallPadding),
                                  color: lightBg,
                                  child: ExpansionTile(
                                      title: Text(
                                        'My online games: (${profileController.multiPlayerWonGamesCount.value} won of ${profileController.multiPlayerResultsObs.value?.length}) ',
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              smallPadding),
                                          child: ListView.builder(
                                              itemCount: profileController
                                                  .multiPlayerResultsObs
                                                  .value!
                                                  .length,
                                              shrinkWrap: true,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return GameCard(
                                                    profileController
                                                        .multiPlayerResultsObs
                                                        .value?[index],
                                                    context);
                                              }),
                                        ),
                                      ]),
                                ),
                              ],
                            );
                          }),
                    DefaultIconButton(
                        height: 60,
                        text: 'sign out',
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Get.offAll(() => LoginScreen());
                          Get.delete<MainController>();
                        },
                        icon: Icons.exit_to_app),
                  ],
                )
              ],
            ),
          ),
        );
      })),
    );
  }

  Stack GameCard(ResultModel result, BuildContext context) {
    result.isMultiPlayer ?? false;
    return Stack(children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(mediumPadding),
          child: Column(
            /* spacing: 20, // to apply margin in the main axis of the wrap
            runSpacing: 20, // to apply margin in the cross axis of the wrap
            alignment: WrapAlignment.spaceBetween,*/
            children: [
              result.isMultiPlayer!
                  ? Text(
                      'Result: ${result.type}',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  : const SizedBox(),
              Text('Category: ${result.category ?? 'Random'}',
                  style: Theme.of(context).textTheme.subtitle1),
              Text(
                'Difficulty: ${result.difficulty ?? 'Random'}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text('Date: ${formatTimeAgo(result.createdAt!)}',
                  style: Theme.of(context).textTheme.subtitle1),
              Container(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                        flex: result.score!,
                        child: Container(
                          color: Colors.green,
                          child: Text(
                            '${result.score!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        )),
                    Expanded(
                        flex: result.maxScore! - result.score!,
                        child: Container(
                          child: Text(
                            '${result.maxScore! - result.score!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          color: Colors.red,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        color: result.type == 'win'
            ? Colors.green[50]
            : result.type == 'draw'
                ? Colors.yellow[50]
                : Colors.red[50],
      ),
    ]);
  }
}
