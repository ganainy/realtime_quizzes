class Category {
  //category name to show user , api_param for API call
  String? categoryName;
  int? api_param;

  Category(this.categoryName, this.api_param);

  Category.withNameOnly(this.categoryName);


  Category.fromJson(var json) {
    categoryName = json['categoryName'];
    api_param = json['apiParam'];
  }

}
