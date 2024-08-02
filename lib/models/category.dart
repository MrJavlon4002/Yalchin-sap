class Category {
  Category({
    required this.id,
    required this.name,
    
  });


  final String id;
  final String name;
  // late String subName = ;
  // bool isSubCat = false;
  // int category_index =1;
  late int size = this.name.split(":").length;

  get headCategory{

    return this.name.split(":").length!=1 ? this.name.split(":")[1] : this.name;
  }

  bool get isSubCat{
    return this.name.split(":").length==2;
  }

  String get subName{
    return this.name.split(":")[0];

  }

  int get ind{
    return this.name.length;
  }

  get hasSubParent{
    if (this.name.split(":").length>=3) {
      return this.name.split(":")[this.name.split(":").length-1]; 
    } 
    return false;
  }

  int get numOfParentCategories{
    return this.name.split(":").length-1;
  }



}
