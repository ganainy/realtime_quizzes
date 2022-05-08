import 'package:realtime_quizzes/models/question.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';

import 'player.dart';

//state of the invite that was sent to a friend
enum InviteStatus {
  OPEN_INVITE, //invite any random can accept
  FRIEND_ACCEPTED_INVITE, //friend accepted invite
  FRIEND_DECLINED_INVITE, //friend declined invite
  SENDER_CANCELED_INVITE, //sender canceled invite
}

class QueueEntryModel {
  InviteStatus? inviteStatus;

  QuizSettings? quizSettings = QuizSettings(
      numberOfQuestions: 10.0, difficulty: "Random", category: "Random");
  String?
      queueEntryId; //this will be also the email of the player to prevent multiple entry to queue by same user

  List<PlayerModel?>? players = [];
  List<QuestionModel?>? questions = [];

  bool hasOpponentLeftGame =
      false; //this flag to notify user that opponent has left the game

  QueueEntryModel(
      {this.queueEntryId,
      this.players,
      this.questions,
      this.quizSettings,
      this.inviteStatus});

  QueueEntryModel.fromJson(var json) {
    queueEntryId = (json['queueEntryId']);
    quizSettings = QuizSettings.fromJson(json['quizSettings']);

    json['players']?.forEach((playerJson) {
      players?.add(PlayerModel.fromJson(playerJson));
    });

    json['questions']?.forEach((questionJson) {
      questions?.add(QuestionModel.fromJson(questionJson));
    });

    hasOpponentLeftGame = (json['hasOpponentLeftGame']);

    switch (json['inviteStatus']) {
      case "OPEN_INVITE":
        inviteStatus = InviteStatus.OPEN_INVITE;
        break;
      case "FRIEND_ACCEPTED_INVITE":
        inviteStatus = InviteStatus.FRIEND_ACCEPTED_INVITE;
        break;
      case "FRIEND_DECLINED_INVITE":
        inviteStatus = InviteStatus.FRIEND_DECLINED_INVITE;
        break;
      case "SENDER_CANCELED_INVITE":
        inviteStatus = InviteStatus.SENDER_CANCELED_INVITE;
        break;
      default:
        throw Exception("InviteStatus not found");
    }
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

  var inviteStatus;

  switch (queueEntryModel?.inviteStatus) {
    case InviteStatus.OPEN_INVITE:
      inviteStatus = "OPEN_INVITE";
      break;
    case InviteStatus.FRIEND_ACCEPTED_INVITE:
      inviteStatus = "FRIEND_ACCEPTED_INVITE";
      break;
    case InviteStatus.FRIEND_DECLINED_INVITE:
      inviteStatus = "FRIEND_DECLINED_INVITE";
      break;
    case InviteStatus.SENDER_CANCELED_INVITE:
      inviteStatus = "SENDER_CANCELED_INVITE";
      break;
    default:
      throw Exception("InviteStatus not found");
  }

  return {
    'queueEntryId': (queueEntryModel?.queueEntryId),
    'quizSettings': quizSettingsToJson(queueEntryModel?.quizSettings),
    'hasOpponentLeftGame': queueEntryModel?.hasOpponentLeftGame,
    'players': playersList,
    'questions': questionsList,
    'inviteStatus': inviteStatus,
  };
}
