//this will be shown to show state of user in search page
enum UserStatus {
  NOT_FRIEND, //this user is not friend with logged user
  FRIEND, //this user is  friend with logged user
  SENT_FRIEND_REQUEST, //logged user already sent friend request to this user
  RECEIVED_FRIEND_REQUEST, //logged user received friend request from this user
  REMOVED_REQUEST, //friend request was sent to logged user but not accepted (removed)
}
UserStatus? userStatusFromJson(json) {
  if (json == null) {
    return null;
  }

  UserStatus? userStatus;

  switch (json) {
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
    case "REMOVED_REQUEST":
      userStatus = UserStatus.REMOVED_REQUEST;
      break;
    default:
      break;
  }
  return userStatus;
}

String? userStatusToJson(UserStatus? userStatus) {
  String? userStatusString;

  switch (userStatus) {
    case UserStatus.NOT_FRIEND:
      userStatusString = "NOT_FRIEND";
      break;
    case UserStatus.FRIEND:
      userStatusString = "FRIEND";
      break;
    case UserStatus.SENT_FRIEND_REQUEST:
      userStatusString = "SENT_FRIEND_REQUEST";
      break;
    case UserStatus.RECEIVED_FRIEND_REQUEST:
      userStatusString = "RECEIVED_FRIEND_REQUEST";
      break;
    case UserStatus.REMOVED_REQUEST:
      userStatusString = "REMOVED_REQUEST";
      break;
    default:
      break;
  }
  return userStatusString;
}
