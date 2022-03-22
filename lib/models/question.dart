import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../shared/converters.dart';


class QuestionModel {
   String? category;
   String? difficulty;
   String? question;
   String? correctAnswer;
   List<dynamic> allAnswers = [];

   List<dynamic>? _incorrectAnswers;
   String? _type;


  QuestionModel.fromJson(questionJson) {
    category = questionJson['category'];
    difficulty = questionJson['difficulty'];
    question = questionJson['question'];
    correctAnswer = questionJson['correct_answer']??questionJson['correctAnswer'];
    _incorrectAnswers = questionJson['incorrect_answers'];

    _type = questionJson['type'];

    if(_incorrectAnswers==null){
      //reading from firebase
      allAnswers=questionJson['allAnswers'];
    }else{
      //reading from Api
      allAnswers = [...?_incorrectAnswers, correctAnswer];
      allAnswers.shuffle();
    }

  }
}

questionModelToJson(QuestionModel? questionModel){
  return{
    'category':questionModel?.category,
    'difficulty':questionModel?.difficulty,
    'question':questionModel?.question,
    'correctAnswer':questionModel?.correctAnswer,
    'allAnswers':questionModel?.allAnswers,
  };
}

