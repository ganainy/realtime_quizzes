import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/single_player_quiz/single_player_quiz_controller.dart';

import '../../models/question.dart';
import '../../shared/components.dart';

class SinglePlayerQuizScreen extends StatelessWidget {
  SinglePlayerQuizScreen({Key? key}) : super(key: key);

  final SinglePlayerQuizController singlePlayerQuizController =
      Get.put(SinglePlayerQuizController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return singlePlayerQuizController.questions.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(singlePlayerQuizController, context);
      }),
    ));
  }

  Question(
    SinglePlayerQuizController singlePlayerQuizController,
    BuildContext context,
  ) {
    QuestionModel? currentQuestion = singlePlayerQuizController.questions.value
        .elementAt(singlePlayerQuizController.currentQuestionIndex.value);

    return WillPopScope(
      onWillPop: () async {
        singlePlayerQuizController.cancelTimer();
        return true;
      },
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40,
                margin: EdgeInsets.all(smallPadding),
                child: Row(children: [
                  ...mapIndexed(singlePlayerQuizController.userAnswers.value,
                      (index, answer) {
                    return Expanded(
                        child: Container(
                      color: (singlePlayerQuizController.userAnswers.value
                                  .elementAt(index) ==
                              singlePlayerQuizController.questions.value
                                  .elementAt(index)
                                  .correctAnswer)
                          ? Colors.green
                          : Colors.red,
                      child: Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ));
                  }).toList(),
                  Expanded(
                    child: const SizedBox(),
                    flex: singlePlayerQuizController.questions.length -
                        singlePlayerQuizController.userAnswers.length,
                  )
                ]
                    /*     [
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
                  ],*/
                    ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.access_alarm,
                    size: 40,
                    color: primaryTextColor,
                  ),
                  Obx(() {
                    return Text(
                      singlePlayerQuizController.timerCounter.value.toString(),
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color:
                              singlePlayerQuizController.timerCounter.value! <=
                                      3
                                  ? Colors.red
                                  : primaryTextColor),
                    );
                  }),
                ],
              ),
              const SizedBox(
                height: largePadding,
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(smallPadding),
                    child: Card(
                      color: Colors.yellow[200],
                      child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(largePadding),
                          child: Text(
                            '${currentQuestion?.question}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.subtitle1,
                          )),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Card(
                      child: Container(
                        margin: EdgeInsets.all(4),
                        child: Text(
                          'Question: ${(singlePlayerQuizController.currentQuestionIndex.value + 1)}/${(singlePlayerQuizController.questions.value.length)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: largePadding,
              ),
              ...?currentQuestion?.allAnswers.map((answer) {
                return Answer(singlePlayerQuizController, answer,
                    currentQuestion.correctAnswer!, context);
              }),
              DefaultButton(
                  text: 'end quiz',
                  onPressed: () {
                    singlePlayerQuizController.endQuiz();
                  }),
              /*  Text(
                  'temporary text right answer: ${currentQuestion?.correctAnswer}'),
         */
            ],
          ),
        ),
      ),
    );
  }

  Answer(
    SinglePlayerQuizController singlePlayerQuizController,
    String text,
    /*answer*/
    String correctAnswer,
    BuildContext context,
  ) {
    return SinglePlayerAnswerButton(
      text: text,
      context: context,
      correctAnswer: correctAnswer,
      singlePlayerQuizController: singlePlayerQuizController,
      onPressed: () {
        //if question is already answered do nothing
        if (!singlePlayerQuizController.isQuestionAnswered.value) {
          singlePlayerQuizController.checkAnswer(
            answer: text,
          );
        }
      },
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}
