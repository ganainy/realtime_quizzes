//contains connections of each user and their relation to logged user
import 'UserStatus.dart';

class Connection {
  String? email;
  UserStatus? userStatus;

  Connection.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    userStatus = userStatusFromJson(json['userStatus']);
  }

  Connection({this.email, this.userStatus});
}

connectionToJson(Connection? connection) {
  return {
    'email': connection?.email,
    'userStatus': userStatusToJson(connection?.userStatus),
  };
}
