import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../models/queue_entry.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

CollectionReference quizzesCollection = firestore.collection('quizzes');
CollectionReference invitesCollection = firestore.collection('invites');
CollectionReference usersCollection = firestore.collection('users');
CollectionReference queueCollection = firestore.collection('queue');
//CollectionReference runningCollection = firestore.collection('running');

enum DownloadState { INITIAL, LOADING, SUCCESS, ERROR }

class Shared {
  static UserModel? loggedUser;

  static QueueEntryModel queueEntryModel = QueueEntryModel(
      difficulty: 'medium'.tr,
      category: 'Random',
      numberOfQuestions:
          10); //the object containing everything related to a game

  static void resetQueueEntry() {
    queueEntryModel = QueueEntryModel(
        difficulty: 'medium'.tr,
        category: 'Random',
        numberOfQuestions: 10); //initial state of the queue entry
  }
}
