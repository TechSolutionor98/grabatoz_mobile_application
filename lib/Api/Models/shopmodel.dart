
import 'dart:convert';

Shopmodel welcomeFromJson(String str) => Shopmodel.fromJson(json.decode(str));

String welcomeToJson(Shopmodel data) => json.encode(data.toJson());

class Shopmodel {
    bool success;
    List<Datum> data;
    Pagination pagination;
    Filters filters;
    AppliedQuery appliedQuery;

    Shopmodel({
        required this.success,
        required this.data,
        required this.pagination,
        required this.filters,
        required this.appliedQuery,
    });

    factory Shopmodel.fromJson(Map<String, dynamic> json) => Shopmodel(
        success: json["success"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
        filters: Filters.fromJson(json["filters"]),
        appliedQuery: AppliedQuery.fromJson(json["appliedQuery"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
        "filters": filters.toJson(),
        "appliedQuery": appliedQuery.toJson(),
    };
}

class AppliedQuery {
    bool isActive;

    AppliedQuery({
        required this.isActive,
    });

    factory AppliedQuery.fromJson(Map<String, dynamic> json) => AppliedQuery(
        isActive: json["isActive"],
    );

    Map<String, dynamic> toJson() => {
        "isActive": isActive,
    };
}

class Datum {
    String id;
    String name;
    String sku;
    String slug;
    String barcode;
    StockStatus stockStatus;
    Brand brand;
    Brand parentCategory;
    Brand category;
    SubCategory2 subCategory2;
    dynamic subCategory3;
    dynamic subCategory4;
    Brand subCategory;
    String description;
    String shortDescription;
    int buyingPrice;
    double price;
    int offerPrice;
    int discount;
    String image;
    List<String> galleryImages;
    List<dynamic> videoGallery;
    int countInStock;
    int lowStockWarning;
    int maxPurchaseQty;
    int weight;
    Unit unit;
    Tax? tax;
    List<String> tags;
    bool isActive;
    bool onHold;
    bool canPurchase;
    bool showStockOut;
    bool refundable;
    bool featured;
    bool hideFromShop;
    int rating;
    int numReviews;
    List<Specification> specifications;
    List<Variation> variations;
    String reverseVariationText;
    String selfVariationText;
    List<dynamic> colorVariations;
    String currentProductColor;
    List<dynamic> dosVariations;
    CreatedBy createdBy;
    List<dynamic> reviews;
    DateTime createdAt;
    DateTime updatedAt;
    int v;
    String video;
    int discountPercentage;
    int finalPrice;
    StockStatusComputed stockStatusComputed;
    bool isOnSale;

    Datum({
        required this.id,
        required this.name,
        required this.sku,
        required this.slug,
        required this.barcode,
        required this.stockStatus,
        required this.brand,
        required this.parentCategory,
        required this.category,
        required this.subCategory2,
        required this.subCategory3,
        required this.subCategory4,
        required this.subCategory,
        required this.description,
        required this.shortDescription,
        required this.buyingPrice,
        required this.price,
        required this.offerPrice,
        required this.discount,
        required this.image,
        required this.galleryImages,
        required this.videoGallery,
        required this.countInStock,
        required this.lowStockWarning,
        required this.maxPurchaseQty,
        required this.weight,
        required this.unit,
        this.tax,
        required this.tags,
        required this.isActive,
        required this.onHold,
        required this.canPurchase,
        required this.showStockOut,
        required this.refundable,
        required this.featured,
        required this.hideFromShop,
        required this.rating,
        required this.numReviews,
        required this.specifications,
        required this.variations,
        required this.reverseVariationText,
        required this.selfVariationText,
        required this.colorVariations,
        required this.currentProductColor,
        required this.dosVariations,
        required this.createdBy,
        required this.reviews,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
        required this.video,
        required this.discountPercentage,
        required this.finalPrice,
        required this.stockStatusComputed,
        required this.isOnSale,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        name: json["name"],
        sku: json["sku"],
        slug: json["slug"],
        barcode: json["barcode"],
        stockStatus: stockStatusValues.map[json["stockStatus"]]!,
        brand: Brand.fromJson(json["brand"]),
        parentCategory: Brand.fromJson(json["parentCategory"]),
        category: Brand.fromJson(json["category"]),
        subCategory2: subCategory2Values.map[json["subCategory2"]]!,
        subCategory3: json["subCategory3"],
        subCategory4: json["subCategory4"],
        subCategory: Brand.fromJson(json["subCategory"]),
        description: json["description"],
        shortDescription: json["shortDescription"],
        buyingPrice: json["buyingPrice"],
        price: json["price"]?.toDouble(),
        offerPrice: json["offerPrice"],
        discount: json["discount"],
        image: json["image"],
        galleryImages: List<String>.from(json["galleryImages"].map((x) => x)),
        videoGallery: List<dynamic>.from(json["videoGallery"].map((x) => x)),
        countInStock: json["countInStock"],
        lowStockWarning: json["lowStockWarning"],
        maxPurchaseQty: json["maxPurchaseQty"],
        weight: json["weight"],
        unit: unitValues.map[json["unit"]]!,
        tax: json["tax"] == null ? null : Tax.fromJson(json["tax"]),
        tags: List<String>.from(json["tags"].map((x) => x)),
        isActive: json["isActive"],
        onHold: json["onHold"],
        canPurchase: json["canPurchase"],
        showStockOut: json["showStockOut"],
        refundable: json["refundable"],
        featured: json["featured"],
        hideFromShop: json["hideFromShop"],
        rating: json["rating"],
        numReviews: json["numReviews"],
        specifications: List<Specification>.from(json["specifications"].map((x) => Specification.fromJson(x))),
        variations: List<Variation>.from(json["variations"].map((x) => Variation.fromJson(x))),
        reverseVariationText: json["reverseVariationText"],
        selfVariationText: json["selfVariationText"],
        colorVariations: List<dynamic>.from(json["colorVariations"].map((x) => x)),
        currentProductColor: json["currentProductColor"],
        dosVariations: List<dynamic>.from(json["dosVariations"].map((x) => x)),
        createdBy: createdByValues.map[json["createdBy"]]!,
        reviews: List<dynamic>.from(json["reviews"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        video: json["video"],
        discountPercentage: json["discountPercentage"],
        finalPrice: json["finalPrice"],
        stockStatusComputed: stockStatusComputedValues.map[json["stockStatusComputed"]]!,
        isOnSale: json["isOnSale"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "sku": sku,
        "slug": slug,
        "barcode": barcode,
        "stockStatus": stockStatusValues.reverse[stockStatus],
        "brand": brand.toJson(),
        "parentCategory": parentCategory.toJson(),
        "category": category.toJson(),
        "subCategory2": subCategory2Values.reverse[subCategory2],
        "subCategory3": subCategory3,
        "subCategory4": subCategory4,
        "subCategory": subCategory.toJson(),
        "description": description,
        "shortDescription": shortDescription,
        "buyingPrice": buyingPrice,
        "price": price,
        "offerPrice": offerPrice,
        "discount": discount,
        "image": image,
        "galleryImages": List<dynamic>.from(galleryImages.map((x) => x)),
        "videoGallery": List<dynamic>.from(videoGallery.map((x) => x)),
        "countInStock": countInStock,
        "lowStockWarning": lowStockWarning,
        "maxPurchaseQty": maxPurchaseQty,
        "weight": weight,
        "unit": unitValues.reverse[unit],
        "tax": tax?.toJson(),
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "isActive": isActive,
        "onHold": onHold,
        "canPurchase": canPurchase,
        "showStockOut": showStockOut,
        "refundable": refundable,
        "featured": featured,
        "hideFromShop": hideFromShop,
        "rating": rating,
        "numReviews": numReviews,
        "specifications": List<dynamic>.from(specifications.map((x) => x.toJson())),
        "variations": List<dynamic>.from(variations.map((x) => x.toJson())),
        "reverseVariationText": reverseVariationText,
        "selfVariationText": selfVariationText,
        "colorVariations": List<dynamic>.from(colorVariations.map((x) => x)),
        "currentProductColor": currentProductColor,
        "dosVariations": List<dynamic>.from(dosVariations.map((x) => x)),
        "createdBy": createdByValues.reverse[createdBy],
        "reviews": List<dynamic>.from(reviews.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "video": video,
        "discountPercentage": discountPercentage,
        "finalPrice": finalPrice,
        "stockStatusComputed": stockStatusComputedValues.reverse[stockStatusComputed],
        "isOnSale": isOnSale,
    };
}

class Brand {
    BrandId id;
    BrandName name;
    Slug slug;

    Brand({
        required this.id,
        required this.name,
        required this.slug,
    });

    factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: brandIdValues.map[json["_id"]]!,
        name: brandNameValues.map[json["name"]]!,
        slug: slugValues.map[json["slug"]]!,
    );

    Map<String, dynamic> toJson() => {
        "_id": brandIdValues.reverse[id],
        "name": brandNameValues.reverse[name],
        "slug": slugValues.reverse[slug],
    };
}

enum BrandId {
    THE_687609800_DE49396755_B8_FF8,
    THE_687609800_DE49396755_B8_FFA,
    THE_687609800_DE49396755_B8_FFE,
    THE_687609800_DE49396755_B9000,
    THE_687609810_DE49396755_B9002,
    THE_691_EF907_C9_EE5_F55_C14_F1_E17,
    THE_691_EF96_BC9_EE5_F55_C14_F1_E72
}

final brandIdValues = EnumValues({
    "687609800de49396755b8ff8": BrandId.THE_687609800_DE49396755_B8_FF8,
    "687609800de49396755b8ffa": BrandId.THE_687609800_DE49396755_B8_FFA,
    "687609800de49396755b8ffe": BrandId.THE_687609800_DE49396755_B8_FFE,
    "687609800de49396755b9000": BrandId.THE_687609800_DE49396755_B9000,
    "687609810de49396755b9002": BrandId.THE_687609810_DE49396755_B9002,
    "691ef907c9ee5f55c14f1e17": BrandId.THE_691_EF907_C9_EE5_F55_C14_F1_E17,
    "691ef96bc9ee5f55c14f1e72": BrandId.THE_691_EF96_BC9_EE5_F55_C14_F1_E72
});

enum BrandName {
    ACER,
    ASUS,
    COMPUTERS,
    HP,
    LAPTOP,
    LENOVO,
    MSI
}

final brandNameValues = EnumValues({
    "Acer": BrandName.ACER,
    "Asus": BrandName.ASUS,
    "Computers": BrandName.COMPUTERS,
    "HP": BrandName.HP,
    "Laptop": BrandName.LAPTOP,
    "Lenovo": BrandName.LENOVO,
    "MSI": BrandName.MSI
});

enum Slug {
    ACER,
    ASUS,
    COMPUTERS,
    HP,
    LAPTOP,
    LENOVO,
    MSI
}

final slugValues = EnumValues({
    "acer": Slug.ACER,
    "asus": Slug.ASUS,
    "computers": Slug.COMPUTERS,
    "hp": Slug.HP,
    "laptop": Slug.LAPTOP,
    "lenovo": Slug.LENOVO,
    "msi": Slug.MSI
});

enum CreatedBy {
    THE_6888_DE5_D341_D9535396_A2569
}

final createdByValues = EnumValues({
    "6888de5d341d9535396a2569": CreatedBy.THE_6888_DE5_D341_D9535396_A2569
});

class Specification {
    String key;
    String value;
    String id;

    Specification({
        required this.key,
        required this.value,
        required this.id,
    });

    factory Specification.fromJson(Map<String, dynamic> json) => Specification(
        key: json["key"],
        value: json["value"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
        "_id": id,
    };
}

enum StockStatus {
    AVAILABLE_PRODUCT
}

final stockStatusValues = EnumValues({
    "Available Product": StockStatus.AVAILABLE_PRODUCT
});

enum StockStatusComputed {
    IN_STOCK,
    OUT_OF_STOCK
}

final stockStatusComputedValues = EnumValues({
    "inStock": StockStatusComputed.IN_STOCK,
    "outOfStock": StockStatusComputed.OUT_OF_STOCK
});

enum SubCategory2 {
    THE_691_EF9_F2_C9_EE5_F55_C14_F1_F3_F,
    THE_691_EFA01_C9_EE5_F55_C14_F1_F52
}

final subCategory2Values = EnumValues({
    "691ef9f2c9ee5f55c14f1f3f": SubCategory2.THE_691_EF9_F2_C9_EE5_F55_C14_F1_F3_F,
    "691efa01c9ee5f55c14f1f52": SubCategory2.THE_691_EFA01_C9_EE5_F55_C14_F1_F52
});

class Tax {
    TaxId id;
    TaxName name;
    int rate;

    Tax({
        required this.id,
        required this.name,
        required this.rate,
    });

    factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        id: taxIdValues.map[json["_id"]]!,
        name: taxNameValues.map[json["name"]]!,
        rate: json["rate"],
    );

    Map<String, dynamic> toJson() => {
        "_id": taxIdValues.reverse[id],
        "name": taxNameValues.reverse[name],
        "rate": rate,
    };
}

enum TaxId {
    THE_6874_DE4481_C33433_C61_F9_BE0,
    THE_68764_A3_CF85736_ADB9_C1_A62_A
}

final taxIdValues = EnumValues({
    "6874de4481c33433c61f9be0": TaxId.THE_6874_DE4481_C33433_C61_F9_BE0,
    "68764a3cf85736adb9c1a62a": TaxId.THE_68764_A3_CF85736_ADB9_C1_A62_A
});

enum TaxName {
    VAT,
    VAT_5
}

final taxNameValues = EnumValues({
    "VAT": TaxName.VAT,
    "VAT 5%": TaxName.VAT_5
});

enum Unit {
    PIECE,
    THE_6874_DE4481_C33433_C61_F9_BDA,
    THE_687609810_DE49396755_B9004,
    THE_68764_A3_DF85736_ADB9_C1_A62_C
}

final unitValues = EnumValues({
    "piece": Unit.PIECE,
    "6874de4481c33433c61f9bda": Unit.THE_6874_DE4481_C33433_C61_F9_BDA,
    "687609810de49396755b9004": Unit.THE_687609810_DE49396755_B9004,
    "68764a3df85736adb9c1a62c": Unit.THE_68764_A3_DF85736_ADB9_C1_A62_C
});

class Variation {
    String product;
    String variationText;
    String id;

    Variation({
        required this.product,
        required this.variationText,
        required this.id,
    });

    factory Variation.fromJson(Map<String, dynamic> json) => Variation(
        product: json["product"],
        variationText: json["variationText"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "product": product,
        "variationText": variationText,
        "_id": id,
    };
}

class Filters {
    String sortBy;

    Filters({
        required this.sortBy,
    });

    factory Filters.fromJson(Map<String, dynamic> json) => Filters(
        sortBy: json["sortBy"],
    );

    Map<String, dynamic> toJson() => {
        "sortBy": sortBy,
    };
}

class Pagination {
    int currentPage;
    int totalPages;
    int totalProducts;
    bool hasNextPage;
    bool hasPrevPage;

    Pagination({
        required this.currentPage,
        required this.totalPages,
        required this.totalProducts,
        required this.hasNextPage,
        required this.hasPrevPage,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["currentPage"],
        totalPages: json["totalPages"],
        totalProducts: json["totalProducts"],
        hasNextPage: json["hasNextPage"],
        hasPrevPage: json["hasPrevPage"],
    );

    Map<String, dynamic> toJson() => {
        "currentPage": currentPage,
        "totalPages": totalPages,
        "totalProducts": totalProducts,
        "hasNextPage": hasNextPage,
        "hasPrevPage": hasPrevPage,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
