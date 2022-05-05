import 'package:html_unescape/html_unescape.dart';

class QuestionModel {
  String? category;
  String? difficulty;
  String? question;
  String? correctAnswer;
  List<dynamic> allAnswers = [];

  List<dynamic>? _incorrectAnswers;
  String? _type;

  var unescape = HtmlUnescape();

  QuestionModel.fromJson(questionJson) {
    category = questionJson['category'];
    difficulty = questionJson['difficulty'];
    question = unescape.convert(questionJson[
        'question']); //remove weird html escape symbols from question
    correctAnswer =
        questionJson['correct_answer'] ?? questionJson['correctAnswer'];
    _incorrectAnswers = questionJson['incorrect_answers'];

    _type = questionJson['type'];

    if (_incorrectAnswers == null) {
      //reading from firebase
      allAnswers = questionJson['allAnswers'];
    } else {
      //reading from Api
      allAnswers = [...?_incorrectAnswers, correctAnswer];
      for (var answer in allAnswers) {
        //remove weird html escape symbols from answers
        answer = unescape.convert(answer);
      }
      allAnswers.shuffle();
    }
  }
}

questionModelToJson(QuestionModel? questionModel) {
  return {
    'category': questionModel?.category,
    'difficulty': questionModel?.difficulty,
    'question': questionModel?.question,
    'correctAnswer': questionModel?.correctAnswer,
    'allAnswers': questionModel?.allAnswers,
  };
}
