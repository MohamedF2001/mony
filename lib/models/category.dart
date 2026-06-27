class Category {
  final int id;
  int? iconid;
  String categoryName;
  int type;
  bool isDeleted = false;

  Category({
    this.id = 0,
    required this.categoryName,
    required this.type,
  });

  setDeleted() {
    isDeleted = true;
    // La sauvegarde doit être gérée par l'API désormais
  }
}

class CategoryType {
  static const int income = 0;
  static const int expense = 1;
}
