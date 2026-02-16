
import 'dart:convert';

List<Menumodel> welcomeFromJson(String str) => List<Menumodel>.from(json.decode(str).map((x) => Menumodel.fromJson(x)));

String welcomeToJson(List<Menumodel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Menumodel {
  Id id;
  String name;
  String slug;
  bool isActive;
  List<Child> children;

  Menumodel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.children,
  });

  factory Menumodel.fromJson(Map<String, dynamic> json) => Menumodel(
    id: idValues.map[json["_id"]]!,
    name: json["name"],
    slug: json["slug"],
    isActive: json["isActive"],
    children: List<Child>.from(json["children"].map((x) => Child.fromJson(x))).where((child) => child.isActive).toList(),
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "name": name,
    "slug": slug,
    "isActive": isActive,
    "children": List<dynamic>.from(children.map((x) => x.toJson())),
  };
}

class Child {
  String id;
  String name;
  String slug;
  int level;
  Id category;
  bool isActive;
  String? parentSubCategory;
  List<Child> children;

  Child({
    required this.id,
    required this.name,
    required this.slug,
    required this.level,
    required this.category,
    required this.isActive,
    required this.parentSubCategory,
    required this.children,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json["_id"],
    name: json["name"],
    slug: json["slug"],
    level: json["level"],
    category: idValues.map[json["category"]]!,
    isActive: json["isActive"],
    parentSubCategory: json["parentSubCategory"],
    children: List<Child>.from(json["children"].map((x) => Child.fromJson(x))).where((child) => child.isActive).toList(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "slug": slug,
    "level": level,
    "category": idValues.reverse[category],
    "isActive": isActive,
    "parentSubCategory": parentSubCategory,
    "children": List<dynamic>.from(children.map((x) => x.toJson())),
  };
}

enum Id {
  THE_687659_FCAC482_FC1560134_D1,
  THE_691_EBEDCC9_EE5_F55_C14_EF323,
  THE_691_EC477_C9_EE5_F55_C14_EFBFF,
  THE_691_EE508_C9_EE5_F55_C14_F1506,
  THE_691_EF907_C9_EE5_F55_C14_F1_E17
}

final idValues = EnumValues({
  "687659fcac482fc1560134d1": Id.THE_687659_FCAC482_FC1560134_D1,
  "691ebedcc9ee5f55c14ef323": Id.THE_691_EBEDCC9_EE5_F55_C14_EF323,
  "691ec477c9ee5f55c14efbff": Id.THE_691_EC477_C9_EE5_F55_C14_EFBFF,
  "691ee508c9ee5f55c14f1506": Id.THE_691_EE508_C9_EE5_F55_C14_F1506,
  "691ef907c9ee5f55c14f1e17": Id.THE_691_EF907_C9_EE5_F55_C14_F1_E17
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
