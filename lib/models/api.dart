import 'package:realtime_quizzes/models/question.dart';

class ApiModel {
  List<QuestionModel> questions = [];
  var responseCode;

  ApiModel.fromJson(json) {
    responseCode = json['response_code'];
    json['results'].forEach((questionJson) {
      questions.add(QuestionModel.fromJson(questionJson));
    });
  }
}
