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

class Shared {
  static UserModel? loggedUser;

  static GameModel game = GameModel(
    gameSettings: GameSettings(
        category: 'Random', difficulty: 'medium'.tr, numberOfQuestions: 10),
  ); //the object containing everything related to a game

  static void resetGame() {
    game = GameModel(
      gameSettings: GameSettings(
          category: 'Random', difficulty: 'medium'.tr, numberOfQuestions: 10),
    ); //initial state of the queue entry
  }
}
