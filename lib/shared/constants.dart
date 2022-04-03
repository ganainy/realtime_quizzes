import 'package:get/get.dart';

class Constants {
  static const YOU_IMAGE =
      'https://firebasestorage.googleapis.com/v0/b/realtime-quizzes.appspot.com/o/users%2FScreenshot_3.png?alt=media&token=f457ca49-48e3-4703-8441-259c4be032a7';

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
      'profile': 'History',
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

  static List<Map<String, dynamic>> difficultyList = [
    {'difficulty': 'easy'.tr, 'api': 'easy'},
    {'difficulty': 'medium'.tr, 'api': 'medium'},
    {'difficulty': 'hard'.tr, 'api': 'hard'},
  ];

  static List<String> categoryNames = [
    'Random'.tr,
    'general_knowledge'.tr,
    'books'.tr,
    'films'.tr,
    'music'.tr,
    'musicals_and_theaters'.tr,
    'television'.tr,
    'video_games'.tr,
    'board_games'.tr,
    'science_and_nature'.tr,
    'computers'.tr,
    'mathematics'.tr,
    'mythology'.tr,
    'sports'.tr,
    'geography'.tr,
    'profile'.tr,
    'politics'.tr,
    'art'.tr,
    'celebrities'.tr,
    'animals'.tr,
  ];

  static List<Map<String, dynamic>> categoryList = [
    {'category': 'Random'.tr, 'api': null},
    {'category': 'general_knowledge'.tr, 'api': 9},
    {'category': 'books'.tr, 'api': 10},
    {'category': 'films'.tr, 'api': 11},
    {'category': 'music'.tr, 'api': 12},
    {'category': 'musicals_and_theaters'.tr, 'api': 13},
    {'category': 'television'.tr, 'api': 14},
    {'category': 'video_games'.tr, 'api': 15},
    {'category': 'board_games'.tr, 'api': 16},
    {'category': 'science_and_nature'.tr, 'api': 17},
    {'category': 'computers'.tr, 'api': 18},
    {'category': 'mathematics'.tr, 'api': 19},
    {'category': 'mythology'.tr, 'api': 20},
    {'category': 'sports'.tr, 'api': 21},
    {'category': 'geography'.tr, 'api': 22},
    {'category': 'profile'.tr, 'api': 23},
    {'category': 'politics'.tr, 'api': 24},
    {'category': 'art'.tr, 'api': 25},
    {'category': 'celebrities'.tr, 'api': 26},
    {'category': 'animals'.tr, 'api': 27}
  ];
}
