import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../shared/converters.dart';

//this class will parse received data from Api then will add some fields and serialize needed fields to upload to firebase
class QuizModelApi {
  //response=0 if api request was successful
  late int responseCode;
  List<QuestionDataApi> questions = [];
  QuizSpecs? quizSpecs;
  //info of the user who created the quiz
  UserModel? user;
  bool? isOnline;
  DateTime? createdAt;
  int? quizId;

  QuizModelApi.fromJson(json) {
    responseCode = json['response_code'];
    //response code == 0 means success
    if (responseCode == 0) {
      json['results'].forEach((questionJson) {
        questions.add(QuestionDataApi.fromJson(questionJson));
      });

      createdAt = DateTime.now();
      quizId = DateTime.now().microsecondsSinceEpoch;
    }
  }

  //shape the shape of the model that will be stored in firebase
  quizModelApiToJson() {
    var questionsSerialized = [];
    questions.forEach((question) {
      questionsSerialized.add(questionDataApiToJson(question));
    });

    return {
      'questions': questionsSerialized,
      'creator': userModelToJson(user),
      'isOnline': isOnline,
      'quizSpecs': quizSpecsToJson(quizSpecs),
      'quizId': quizId,
      'createdAt': createdAt,
    };
  }
}

//this class will parse received quiz data from firestore
class QuizModelFireStore {
  List<QuestionDataFireStore> questions = [];
  QuizSpecs? quizSpecs;
  //info of the user who created the quiz
  UserModel? user;
  bool? isOnline;
  DateTime? createdAt;
  int? quizId;

  QuizModelFireStore.fromJson(var json) {
    createdAt = (json['createdAt'] as Timestamp).toDate();
    quizId = json['quizId'];
    isOnline = json['isOnline'];
    user = UserModel.fromJson(json['creator']);
    quizSpecs = QuizSpecs.fromJson(json['quizSpecs']);
    json['questions'].forEach((questionJson) {
      questions.add(QuestionDataFireStore.fromJson(questionJson));
    });
  }

  quizModelFireStoreToJson() {
    var questionsSerialized = [];
    questions.forEach((question) {
      questionsSerialized.add(questionDataFireStoreToJson(question));
    });

    return {
      'questions': questionsSerialized,
      'creator': userModelToJson(user),
      'isOnline': isOnline,
      'quizSpecs': quizSpecsToJson(quizSpecs),
      'quizId': quizId,
      'createdAt': createdAt,
    };
  }
}

class QuestionDataFireStore {
  String? category;
  String? difficulty;
  String? question;
  String? correctAnswer;
  List<dynamic> allAnswers = [];

  QuestionDataFireStore.fromJson(questionJson) {
    category = questionJson['category'];
    difficulty = questionJson['difficulty'];
    question = questionJson['question'];
    correctAnswer = questionJson['correctAnswer'];
    allAnswers = questionJson['allAnswers'];
  }
}

class QuestionDataApi {
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

  QuestionDataApi.fromJson(questionJson) {
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
