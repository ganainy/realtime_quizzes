
import '../models/player.dart';
import '../models/question.dart';
import '../models/quiz_specs.dart';
import '../models/user.dart';

quizSpecsToJson(QuizSpecs? quizSpecs) {
  return {
    'difficulty': quizSpecs?.difficulty,
    'amount': quizSpecs?.numberOfQuestions,
    'category': quizSpecs?.category,
  };
}

userModelToJson(UserModel? user) {
  return {
    'name': user?.name,
    'email': user?.email,
    'imageUrl': user?.imageUrl,
  };
}

questionDataApiToJson(QuestionModel question) {
  return {
    'category': question.category,
    'question': question.question,
    'allAnswers': question.allAnswers,
    'correctAnswer': question.correctAnswer,
  };
}

/*inviteModelToJson(InviteModel inviteModel) {
  var playersList = [];
  inviteModel.players.forEach((player) {
    playersList.add(playerModelToJson(player));
  });

  return {
    'quiz': inviteModel.quiz.quizModelFireStoreToJson(),
    'players': playersList,
  };
  }
}*/




