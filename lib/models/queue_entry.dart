import 'package:realtime_quizzes/models/question.dart';

import 'player.dart';

class QueueEntryModel {
  //difficultyType to show user , api_param for API call

  String? difficulty;
  String? category;
  int? numberOfQuestions;
  String?
      queueEntryId; //this will be also the email of the player to prevent multiple entry to queue by same user
  List<PlayerModel?>? players = [];
  List<QuestionModel?>? questions = [];
  int? createdAt; //milliseconssinceepoch
  String?
      invitedFriend; //this field used when sending invite to friends not with random queue
  bool hasFriendDeclinedInvite =
      false; //this field used when sending invite to friends not with random queue
  bool hasFriendAcceptedInvite =
      false; //this field used when sending invite to friends not with random queue

  QueueEntryModel(this.difficulty, this.category, this.numberOfQuestions,
      this.queueEntryId, this.players, this.createdAt);

  QueueEntryModel.fromJson(var json) {
    difficulty = json['difficulty'] ?? 'Random';
    category = json['category'] ?? 'Random';
    createdAt = json['createdAt'];
    numberOfQuestions = (json['numberOfQuestions']);
    queueEntryId = (json['queueEntryId']);
    invitedFriend = (json['invitedFriend']);
    hasFriendDeclinedInvite = (json['hasFriendDeclinedInvite']);
    hasFriendAcceptedInvite = (json['hasFriendAcceptedInvite']);

    json['players']?.forEach((playerJson) {
      players?.add(PlayerModel.fromJson(playerJson));
    });

    json['questions']?.forEach((questionJson) {
      questions?.add(QuestionModel.fromJson(questionJson));
    });
  }
}

queueEntryModelToJson(QueueEntryModel? queueEntryModel) {
  var playersList = [];
  var questionsList = [];
  queueEntryModel?.players?.forEach((player) {
    playersList.add(playerModelToJson(player));
  });

  queueEntryModel?.questions?.forEach((question) {
    questionsList.add(questionModelToJson(question));
  });

  return {
    'difficulty': (queueEntryModel?.difficulty),
    'category': (queueEntryModel?.category),
    'numberOfQuestions': (queueEntryModel?.numberOfQuestions),
    'queueEntryId': (queueEntryModel?.queueEntryId),
    'createdAt': (queueEntryModel?.createdAt),
    'players': playersList,
    'invitedFriend': queueEntryModel?.invitedFriend,
    'hasFriendDeclinedInvite': queueEntryModel?.hasFriendDeclinedInvite,
    'hasFriendAcceptedInvite': queueEntryModel?.hasFriendAcceptedInvite,
    'questions': questionsList,
  };
}
