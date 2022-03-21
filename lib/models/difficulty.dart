class Difficulty {
  //difficultyType to show user , api_param for API call
  String? difficultyType;
  String? api_param;

  Difficulty(this.difficultyType, this.api_param);
  Difficulty.withTypeOnly(this.difficultyType);

  Difficulty.fromJson(var json) {
    difficultyType = json['difficultyType'];
    api_param = json['apiParam'];
  }
}
