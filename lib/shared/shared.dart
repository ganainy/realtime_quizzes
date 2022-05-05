import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:realtime_quizzes/models/user.dart';

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
  static String? queueEntryId =
      ''; //this will hold the queue id of latest game so we can cancel it
  static String category = 'Random';
  static String difficulty = 'Random';
  static int numQuestions = 10;
}
