class AnswerModel {
  String? answer;
  bool isCorrectAnswer = false; //this param will be used to calculate score

  AnswerModel({required this.answer, this.isCorrectAnswer = false});

  AnswerModel.fromJson(json) {
    answer = json['answer'];
    isCorrectAnswer = json['isCorrectAnswer'];
  }
}

answerModelToJson(AnswerModel? answerModel) {
  return {
    'answer': answerModel?.answer,
    'isCorrectAnswer': answerModel?.isCorrectAnswer,
  };
}
