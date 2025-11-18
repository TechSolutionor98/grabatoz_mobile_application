class Newproductmodel {
  String? id;
  String? name;
  String? sku;
  String? slug;
  String? barcode;
  String? stockStatus;
  BrandModel? brand;
  CategoryModel? parentCategory;
  CategoryModel? category;
  CategoryModel? subCategory;
  String? description;
  String? shortDescription;
  int? buyingPrice;
  int? price;
  int? offerPrice;
  int? discount;
  String? image;
  List<dynamic>? galleryImages;
  int? countInStock;
  int? lowStockWarning;
  int? maxPurchaseQty;
  int? weight;
  String? unit;
  String? tax;
  List<String>? tags;
  bool? isActive;
  bool? canPurchase;
  bool? showStockOut;
  bool? refundable;
  bool? featured;
  double? rating;
  int? numReviews;
  List<dynamic>? specifications;
  String? createdBy;
  List<dynamic>? reviews;
  String? createdAt;
  String? updatedAt;
  int? v;

  Newproductmodel({
    this.id,
    this.name,
    this.sku,
    this.slug,
    this.barcode,
    this.stockStatus,
    this.brand,
    this.parentCategory,
    this.category,
    this.subCategory,
    this.description,
    this.shortDescription,
    this.buyingPrice,
    this.price,
    this.offerPrice,
    this.discount,
    this.image,
    this.galleryImages,
    this.countInStock,
    this.lowStockWarning,
    this.maxPurchaseQty,
    this.weight,
    this.unit,
    this.tax,
    this.tags,
    this.isActive,
    this.canPurchase,
    this.showStockOut,
    this.refundable,
    this.featured,
    this.rating,
    this.numReviews,
    this.specifications,
    this.createdBy,
    this.reviews,
    this.createdAt,
    this.updatedAt,
    this.v,
  });
  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "sku": sku,
        "slug": slug,
        "barcode": barcode,
        "stockStatus": stockStatus,
        "brand": brand?.toJson(),
        "parentCategory": parentCategory?.toJson(),
        "category": category?.toJson(),
        "subCategory": subCategory?.toJson(),
        "description": description,
        "shortDescription": shortDescription,
        "buyingPrice": buyingPrice,
        "price": price,
        "offerPrice": offerPrice,
        "discount": discount,
        "image": image,
        "galleryImages": galleryImages,
        "countInStock": countInStock,
        "lowStockWarning": lowStockWarning,
        "maxPurchaseQty": maxPurchaseQty,
        "weight": weight,
        "unit": unit,
        "tax": tax,
        "tags": tags,
        "isActive": isActive,
        "canPurchase": canPurchase,
        "showStockOut": showStockOut,
        "refundable": refundable,
        "featured": featured,
        "rating": rating,
        "numReviews": numReviews,
        "specifications": specifications,
        "createdBy": createdBy,
        "reviews": reviews,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
      };

  factory Newproductmodel.fromJson(Map<String, dynamic> json) =>
      Newproductmodel(
        id: json["_id"],
        name: json["name"],
        sku: json["sku"],
        slug: json["slug"],
        barcode: json["barcode"],
        stockStatus: json["stockStatus"],
        brand:
            json["brand"] != null ? BrandModel.fromJson(json["brand"]) : null,
        parentCategory: json["parentCategory"] != null
            ? CategoryModel.fromJson(json["parentCategory"])
            : null,
        category: json["category"] != null
            ? CategoryModel.fromJson(json["category"])
            : null,
        subCategory: json["subCategory"] != null
            ? CategoryModel.fromJson(json["subCategory"])
            : null,
        description: json["description"],
        shortDescription: json["shortDescription"],
        buyingPrice: json["buyingPrice"] == null ? null : (json["buyingPrice"] as num?)?.toInt(),
        price: json["price"] == null ? null : (json["price"] as num?)?.toInt(),
        offerPrice: json["offerPrice"] == null ? null : (json["offerPrice"] as num?)?.toInt(),
        discount: json["discount"] == null ? null : (json["discount"] as num?)?.toInt(),
        image: json["image"],
        galleryImages: json["galleryImages"] == null ? [] : List<dynamic>.from(json["galleryImages"]),
        countInStock: json["countInStock"] == null ? null : (json["countInStock"] as num?)?.toInt(),
        lowStockWarning: json["lowStockWarning"] == null ? null : (json["lowStockWarning"] as num?)?.toInt(),
        maxPurchaseQty: json["maxPurchaseQty"] == null ? null : (json["maxPurchaseQty"] as num?)?.toInt(),
        weight: json["weight"] == null ? null : (json["weight"] as num?)?.toInt(),
        unit: json["unit"],
        tax: json["tax"]?.toString(),
        tags: json["tags"] == null ? [] : List<String>.from(json["tags"]),
        isActive: json["isActive"],
        canPurchase: json["canPurchase"],
        showStockOut: json["showStockOut"],
        refundable: json["refundable"],
        featured: json["featured"],
        rating: json["rating"] == null ? 0.0 : (json["rating"] as num?)?.toDouble() ?? 0.0,
        numReviews: json["numReviews"] == null ? null : (json["numReviews"] as num?)?.toInt(),
        specifications: json["specifications"],
        createdBy: json["createdBy"],
        reviews: json["reviews"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"] == null ? null : (json["__v"] as num?)?.toInt(),
      );
}

class BrandModel {
  String? id;
  String? name;
  String? slug;

  BrandModel({this.id, this.name, this.slug});

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: json["_id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "slug": slug,
      };
}

class CategoryModel {
  String? id;
  String? name;
  String? slug;

  CategoryModel({this.id, this.name, this.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["_id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "slug": slug,
      };
}
