import 'package:get/get.dart';

import '../models/category.dart';
import '../models/difficulty.dart';

class Constants {
  static Map<String, Map<String, String>> translation = {
    'en_US': {
      'num_questions': 'Number of Questions',
      'category': 'Category',
      'create_quiz': 'Create quiz',
      'find_quiz': 'Find quiz',
      'difficulty': 'Difficulty',
      'general_knowledge': 'General Knowledge',
      'books': 'Books',
      'films': 'Films',
      'music': 'Music',
      'musicals_and_theaters': 'Musicals & Theaters',
      'television': 'Television',
      'video_games': 'Video Games',
      'board_games': 'Board Games',
      'science_and_nature': 'Science & Nature',
      'computers': 'Computers',
      'mathematics': 'Mathematics',
      'mythology': 'Mythology',
      'sports': 'Sports',
      'geography': 'Geography',
      'history': 'History',
      'politics': 'Politics',
      'art': 'Art',
      'celebrities': 'Celebrities',
      'animals': 'Animals',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'difficulty': 'Difficulty',
      'this_error_occurred_while_loading_quiz':
          'This error occurred while loading quiz: ',
      'error_loading_quiz': 'Error loading quiz',
      'continue_as_guest': 'Continue as guest',
    },
    'de_DE': {}
  };

  static List<Difficulty> difficultyList = [
    Difficulty('easy'.tr, 'easy'),
    Difficulty('medium'.tr, 'medium'),
    Difficulty('hard'.tr, 'hard'),
  ];

  //todo remove
  static List<Category> categoryListTesting = [
    Category('general_knowledge'.tr, 9),
    Category('books'.tr, 10),
    Category('films'.tr, 11),
    Category('music'.tr, 12),
  ];

  static List<Category> categoryList = [
    Category('general_knowledge'.tr, 9),
    Category('books'.tr, 10),
    Category('films'.tr, 11),
    Category('music'.tr, 12),
    Category('musicals_and_theaters'.tr, 13),
    Category('television'.tr, 14),
    Category('video_games'.tr, 15),
    Category('board_games'.tr, 16),
    Category('science_and_nature'.tr, 17),
    Category('computers'.tr, 18),
    Category('mathematics'.tr, 19),
    Category('mythology'.tr, 20),
    Category('sports'.tr, 21),
    Category('geography'.tr, 22),
    Category('history'.tr, 23),
    Category('politics'.tr, 24),
    Category('art'.tr, 25),
    Category('celebrities'.tr, 26),
    Category('animals'.tr, 27),
  ];
}

class GameType {
  static const SINGLE = 'single';
  static const VS_FRIEND = 'vs_friend';
  static const VS_RANDOM = 'vs_random';
  static const VS_RANDOMS = 'vs_randoms';
}
