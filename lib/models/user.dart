class UserModel {
  //difficultyType to show user , api_param for API call

  String? name;
  String? email;
  String? imageUrl;
  bool? isOnline; //todo this value will change based on if user online or not

  UserModel(this.name, this.email, this.imageUrl);

  UserModel.fromJson(var json) {
    name = json['name'];
    email = json['email'];
    imageUrl = json['imageUrl'];
  }
}
