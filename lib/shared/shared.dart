import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../models/game.dart';
import '../models/quiz_settings.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

CollectionReference usersCollection = firestore.collection('users');
CollectionReference gameCollection = firestore.collection('games');

const DEFAULT_PLAYER_IMAGE_URL =
    'https://firebasestorage.googleapis.com/v0/b/realtime-quizzes.appspot.com/o/user.png?alt=media&token=eab498e2-1a06-4204-abde-49793c305f29';

class Shared {
  static UserModel? loggedUser = UserModel(email: auth.currentUser?.email);

  static GameModel game = GameModel(
    gameSettings: GameSettings(
        category: 'Random', difficulty: 'medium'.tr, numberOfQuestions: 10),
  ); //the object containing everything related to a game

  /*static void resetGame() {
    game = GameModel(
      gameSettings: GameSettings(
          category: 'Random', difficulty: 'medium'.tr, numberOfQuestions: 10),
    ); //initial state of the queue entry
  }*/
}
