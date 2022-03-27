import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

CollectionReference quizzesCollection = firestore.collection('quizzes');
CollectionReference invitesCollection = firestore.collection('invites');
CollectionReference usersCollection = firestore.collection('users');
CollectionReference queueCollection = firestore.collection('queue');
CollectionReference runningCollection = firestore.collection('running');

enum DownloadState { INITIAL, LOADING, SUCCESS, ERROR }
