class UserModel {
  //difficultyType to show user , api_param for API call

  String? name;
  String? email;
  String? imageUrl;
  bool? isOnline;
  List<dynamic>? quizzesIds;

  UserModel(this.name, this.email, this.imageUrl);

  UserModel.fromJson(var json) {
    name = json['name'];
    email = json['email'];
    imageUrl = json['imageUrl'];
    quizzesIds = json['quizzesIds'];
    isOnline = json['isOnline'];
  }
}
