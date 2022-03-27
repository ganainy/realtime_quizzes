import 'package:realtime_quizzes/models/result.dart';

class UserModel {
  //difficultyType to show user , api_param for API call

  String? name;
  String? email;
  String? imageUrl;
  bool? isOnline;
  var results = []; // list of ResultModel
  var friends = []; //list of String
  List<dynamic> receivedFriendRequests = [];
  List<dynamic> sentFriendRequests = [];

  UserModel({required this.name, required this.email, this.imageUrl});

  UserModel.fromJson(var json) {
    name = json['name'];
    email = json['email'];
    imageUrl = json['imageUrl'];
    friends = json['friends'] ?? [];
    receivedFriendRequests = json['receivedFriendRequests'] ?? [];
    sentFriendRequests = json['sentFriendRequests'] ?? [];
    isOnline = json['isOnline'];
    if (json['results'] != null) {
      json['results'].forEach((result) {
        results.add(ResultModel.fromJson(result));
      });
    }
  }
}

userModelToJson(UserModel? userModel) {
  var resultsJson = [];
  userModel?.results.forEach((result) {
    resultsJson.add(resultModelToJson(result));
  });

  return {
    'name': userModel?.name,
    'email': userModel?.email,
    'imageUrl': userModel?.imageUrl,
    'isOnline': userModel?.isOnline,
    'results': resultsJson,
    'friends': userModel?.friends,
    'receivedFriendRequests': userModel?.receivedFriendRequests,
    'sentFriendRequests': userModel?.sentFriendRequests,
  };
}
