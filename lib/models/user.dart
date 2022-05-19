import 'package:realtime_quizzes/models/result.dart';

import 'Connection.dart';

class UserModel {
  //difficultyType to show user , api_param for API call
  String name = '';
  String? email;
  String? imageUrl;
  bool isOnline = true;
  var results = []; // list of ResultModel
  List<Connection?> connections = []; //list of Connection

  UserModel({this.name = '', required this.email, this.imageUrl});

  UserModel.fromJson(var json) {
    name = json['name'] ?? '';
    email = json['email'];
    imageUrl = json['imageUrl'];
    isOnline = json['isOnline'];
    if (json['results'] != null) {
      json['results'].forEach((result) {
        results.add(ResultModel.fromJson(result));
      });
    }

    if (json['connections'] != null) {
      json['connections'].forEach((connection) {
        connections.add(Connection.fromJson(connection));
      });
    }
  }
}

userModelToJson(UserModel? userModel) {
  var resultsJson = [];
  userModel?.results.forEach((result) {
    resultsJson.add(resultModelToJson(result));
  });

  var connectionsJson = [];
  userModel?.connections.forEach((connection) {
    connectionsJson.add(connectionToJson(connection));
  });

  return {
    'name': userModel?.name,
    'email': userModel?.email,
    'imageUrl': userModel?.imageUrl,
    'isOnline': userModel?.isOnline,
    'results': resultsJson,
    'connections': connectionsJson,
  };
}
