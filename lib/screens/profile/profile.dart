import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import '../../models/result.dart';
import '../../shared/components.dart';
import '../login/login.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Obx(() {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultStatusImage(
                    imageUrl: profileController.userObs.value?.imageUrl,
                    isOnline: profileController.userObs.value?.isOnline,
                    width: 140.0,
                    height: 140.0),
                Text(
                  '${profileController.userObs.value?.name}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                profileController.multiPlayerResultsObs.value == null &&
                        profileController.singlePlayerResultsObs.value == null
                    ? const Center(child: CircularProgressIndicator())
                    : Obx(() {
                        return Column(
                          children: [
                            ExpansionTile(
                                title: const Text('My online games'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(smallPadding),
                                    child: ListView.builder(
                                        itemCount: profileController
                                            .multiPlayerResultsObs
                                            .value!
                                            .length,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return GameCard(
                                              profileController
                                                  .multiPlayerResultsObs.value!
                                                  .elementAt(index),
                                              context);
                                        }),
                                  ),
                                ]),
                            ExpansionTile(
                                title: const Text('my offline games'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(smallPadding),
                                    child: ListView.builder(
                                        itemCount: profileController
                                            .singlePlayerResultsObs
                                            .value!
                                            .length,
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return GameCard(
                                              profileController
                                                  .singlePlayerResultsObs.value!
                                                  .elementAt(index),
                                              context);
                                        }),
                                  ),
                                ]),
                          ],
                        );
                      }),
                DefaultIconButton(
                    text: 'sign out',
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Get.offAll(() => LoginScreen());
                    },
                    icon: Icons.exit_to_app),
              ],
            ),
          ),
        );
      })),
    );
  }

  Stack GameCard(ResultModel result, BuildContext context) {
    result.isMultiPlayer ??= false;
    return Stack(children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(mediumPadding),
          child: Column(
            /* spacing: 20, // to apply margin in the main axis of the wrap
            runSpacing: 20, // to apply margin in the cross axis of the wrap
            alignment: WrapAlignment.spaceBetween,*/
            children: [
              Text(
                'Result: ${result.type}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
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
