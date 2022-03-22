


import 'package:realtime_quizzes/models/question.dart';

class ApiModel{

var questions=[];
var responseCode;

ApiModel.fromJson(json){

  responseCode=json['response_code'];
    json['results'].forEach((questionJson){
      questions.add(QuestionModel.fromJson(questionJson));
    });
  }

}
