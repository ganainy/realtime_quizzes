import 'package:realtime_quizzes/models/question.dart';
import 'package:realtime_quizzes/shared/converters.dart';

import 'player.dart';

class QueueEntryModel {
  //difficultyType to show user , api_param for API call

  String? difficulty;
  String? category;
  int? numberOfQuestions;
  String? queueEntryId; //this will be also the email of the player to prevent multiple entry to queue by same user
  List<PlayerModel?> players=[];
  List<QuestionModel?> questions=[];

  QueueEntryModel(this.difficulty, this.category, this.numberOfQuestions,this.queueEntryId,this.players);

  QueueEntryModel.fromJson(var json) {
    difficulty = json['difficulty'];
    category = json['category'];
     numberOfQuestions = (json['numberOfQuestions']);
    queueEntryId = (json['queueEntryId']);
        json['players'].forEach((playerJson){
          players.add( PlayerModel.fromJson(playerJson) );
        });

    json['questions']?.forEach((questionJson){
      questions.add( QuestionModel.fromJson(questionJson) );
    });

  }
}

queueEntryModelToJson(QueueEntryModel queueEntryModel){

  var playersList = [];
  var questionsList = [];
  queueEntryModel.players.forEach((player) {
    playersList.add(playerModelToJson(player));
  });

  queueEntryModel.questions.forEach((question) {
    questionsList.add(questionModelToJson(question));
  });


return{
  'difficulty':(queueEntryModel.difficulty),
  'category':(queueEntryModel.category),
  'numberOfQuestions':(queueEntryModel.numberOfQuestions),
  'queueEntryId':(queueEntryModel.queueEntryId),
  'players': playersList,
  'questions': questionsList,
 };
}
