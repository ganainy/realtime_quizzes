import '../models/invite.dart';
import '../models/quiz.dart';
import '../models/quiz_specs.dart';
import '../models/user.dart';

quizSpecsToJson(QuizSpecs? quizSpecs) {
  return {
    'difficulty': quizSpecs?.selectedDifficulty?.difficultyType,
    'amount': quizSpecs?.numberOfQuestions,
    'category': quizSpecs?.selectedCategory?.categoryName,
  };
}

userModelToJson(UserModel? user) {
  return {
    'name': user?.name,
    'email': user?.email,
    'imageUrl': user?.imageUrl,
  };
}

questionDataApiToJson(QuestionDataApi question) {
  return {
    'category': question.category,
    'question': question.question,
    'allAnswers': question.allAnswers,
    'correctAnswer': question.correctAnswer,
  };
}

questionDataFireStoreToJson(QuestionDataFireStore question) {
  return {
    'category': question.category,
    'question': question.question,
    'allAnswers': question.allAnswers,
    'correctAnswer': question.correctAnswer,
  };
}

inviteModelToJson(InviteModel inviteModel) {
  return {
    'quiz': inviteModel.quiz.quizModelFireStoreToJson(),
    'players': inviteModel.players,
  };
}
