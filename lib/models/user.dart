import 'package:realtime_quizzes/models/result.dart';

//this will be shown to show state of user in search page
enum UserStatus {
  NOT_FRIEND, //this user is not friend with logged user
  FRIEND, //this user is  friend with logged user
  SENT_FRIEND_REQUEST, //this user already sent friend request to logged user
  RECEIVED_FRIEND_REQUEST, //this user already received friend request from logged user
}

class UserModel {
  //difficultyType to show user , api_param for API call

  String name = '';
  String? email;
  String? imageUrl;
  bool? isOnline;
  var results = []; // list of ResultModel
  var friends = []; //list of String
  var removedRequests =
      []; //save friend requests that were removed and not accepted
  List<dynamic> receivedFriendRequests = [];
  List<dynamic> sentFriendRequests = [];
  UserStatus? userStatus;

  UserModel(
      {this.name = '', required this.email, this.imageUrl, this.userStatus});

  UserModel.fromJson(var json) {
    name = json['name'] ?? '';
    email = json['email'];
    imageUrl = json['imageUrl'];
    friends = json['friends'] ?? [];
    removedRequests = json['removedRequests'] ?? [];
    receivedFriendRequests = json['receivedFriendRequests'] ?? [];
    sentFriendRequests = json['sentFriendRequests'] ?? [];
    isOnline = json['isOnline'];
    if (json['results'] != null) {
      json['results'].forEach((result) {
        results.add(ResultModel.fromJson(result));
      });
    }

    switch (json['inviteStatus']) {
      case "NOT_FRIEND":
        userStatus = UserStatus.NOT_FRIEND;
        break;
      case "FRIEND":
        userStatus = UserStatus.FRIEND;
        break;
      case "RECEIVED_FRIEND_REQUEST":
        userStatus = UserStatus.RECEIVED_FRIEND_REQUEST;
        break;
      case "SENT_FRIEND_REQUEST":
        userStatus = UserStatus.SENT_FRIEND_REQUEST;
        break;
      default:
        break;
    }
  }
}

userModelToJson(UserModel? userModel) {
  var resultsJson = [];
  userModel?.results.forEach((result) {
    resultsJson.add(resultModelToJson(result));
  });

  var userStatus;

  switch (userModel?.userStatus) {
    case UserStatus.NOT_FRIEND:
      userStatus = "NOT_FRIEND";
      break;
    case UserStatus.FRIEND:
      userStatus = "FRIEND";
      break;
    case UserStatus.SENT_FRIEND_REQUEST:
      userStatus = "SENT_FRIEND_REQUEST";
      break;
    case UserStatus.RECEIVED_FRIEND_REQUEST:
      userStatus = "RECEIVED_FRIEND_REQUEST";
      break;
    default:
      break;
  }

  return {
    'name': userModel?.name,
    'email': userModel?.email,
    'imageUrl': userModel?.imageUrl,
    'isOnline': userModel?.isOnline,
    'results': resultsJson,
    'friends': userModel?.friends,
    'removedRequests': userModel?.removedRequests,
    'receivedFriendRequests': userModel?.receivedFriendRequests,
    'sentFriendRequests': userModel?.sentFriendRequests,
    'userStatus': userModel?.userStatus,
  };
}
