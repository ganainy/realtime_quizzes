import 'package:realtime_quizzes/models/category.dart';
import 'package:realtime_quizzes/models/difficulty.dart';
import 'package:realtime_quizzes/shared/converters.dart';

import 'invite.dart';

class QueueEntryModel {
  //difficultyType to show user , api_param for API call

  Difficulty? difficulty;
  Category? category;
  int? numberOfQuestions;
  String? queueEntryId; //this will be also the email of the player to prevent multiple entry to queue by same user
  List<PlayerModel> players=[];


  QueueEntryModel(this.difficulty, this.category, this.numberOfQuestions,this.queueEntryId,this.players);

  QueueEntryModel.fromJson(var json) {
    difficulty = Difficulty.fromJson(json['difficulty']);
    category = Category.fromJson(json['category']);
    numberOfQuestions = (json['numberOfQuestions']);
    queueEntryId = (json['queueEntryId']);

        json['players'].forEach((playerJson){
          players.add( PlayerModel.fromJson(playerJson) );
        });

  }
}

queueEntryModelToJson(QueueEntryModel queueEntryModel){

  var playersList = [];
  queueEntryModel.players.forEach((player) {
    playersList.add(playerModelToJson(player));
  });


return{
  'difficulty':difficultyModelToJson(queueEntryModel.difficulty),
  'category':categoryModelToJson(queueEntryModel.category),
  'numberOfQuestions':(queueEntryModel.numberOfQuestions),
  'queueEntryId':(queueEntryModel.queueEntryId),
  'players': playersList,

};
}
