import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/models/user.dart';

class QuizModel {
  //response=0 if api request was successful
  late int responseCode;
  List<QuestionData> questions = [];
  QuizSpecs? quizSpecs;
  //info of the user who created the quiz
  UserModel? user;
  bool?
      isOnline; //todo this value will change based on if user is online or not
  DateTime? createdAt;
  int? quizId;

  QuizModel.fromJson(json) {
    responseCode = json['response_code'];
    //response code == 0 means success
    if (responseCode == 0) {
      json['results'].forEach((questionJson) {
        questions.add(QuestionData.fromJson(questionJson));
      });

      createdAt = DateTime.now();
      quizId = DateTime.now().microsecondsSinceEpoch;
    }
  }

  //shape the shape of the model that will be stored in firebase
  toMap() {
    var questionsSerialized = [];
    questions.forEach((question) {
      questionsSerialized.add(questionDataToJson(question));
    });

    return {
      'questions': questionsSerialized,
      'creator': userModelToJson(user),
      'isOnline': isOnline,
      'quizSpecs': quizSpecsToJson(quizSpecs),
      'quizId': quizId,
    };
  }

  quizSpecsToJson(QuizSpecs? quizSpecs) {
    return {
      'difficulty': quizSpecs?.selectedDifficulty.difficultyType,
      'amount': quizSpecs?.numberOfQuestions,
      'category': quizSpecs?.selectedCategory.categoryName,
    };
  }

  userModelToJson(UserModel? user) {
    return {
      'name': user?.name,
      'email': user?.email,
      'imageUrl': user?.imageUrl,
    };
  }

  questionDataToJson(QuestionData question) {
    return {
      'category': question.category,
      'question': question.question,
      'allAnswers': question.allAnswers,
      'correctAnswer': question.correctAnswer,
    };
  }
}

class QuestionData {
  late String category;
  late String type;
  late String difficulty;
  late String question;
  late String correctAnswer;
  late List<dynamic> incorrectAnswers;
  List<String> allAnswers = [];

  /*List<String> get shuffledAnswers {
    if (allAnswers.isEmpty) {
      allAnswers = ;
      allAnswers.shuffle();
    }
    return allAnswers;
  }*/

  QuestionData.fromJson(questionJson) {
    category = questionJson['category'];
    type = questionJson['type'];
    difficulty = questionJson['difficulty'];
    question = questionJson['question'];
    correctAnswer = questionJson['correct_answer'];
    incorrectAnswers = questionJson['incorrect_answers'];
    allAnswers = [...incorrectAnswers, correctAnswer];
    allAnswers.shuffle();
  }
}
