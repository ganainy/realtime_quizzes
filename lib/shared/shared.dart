import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

CollectionReference quizzesCollection = firestore.collection('quizzes');
CollectionReference usersCollection = firestore.collection('users');

enum DownloadState { INITIAL, LOADING, SUCCESS, ERROR }