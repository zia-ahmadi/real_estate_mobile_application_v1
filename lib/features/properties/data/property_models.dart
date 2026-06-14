class Property {
  final int id;
  final String title;
  final String description;
  final double price;
  final String city;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String status; // 'available' or 'sold'
  final String? coverImage;
  final List<String> images;
  final bool isFavourited;
  final String? createdAt;
  final String? updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.address,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.status,
    this.coverImage,
    required this.images,
    this.isFavourited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      city: json['city'] as String,
      address: json['address'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      area: (json['area'] as num).toDouble(),
      status: json['status'] as String,
      coverImage: json['cover_image'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavourited: json['is_favourited'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'city': city,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'status': status,
      'cover_image': coverImage,
      'images': images,
      'is_favourited': isFavourited,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAvailable => status == 'available';
  bool get isSold => status == 'sold';
}

class PropertyListResponse {
  final List<Property> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PropertyListResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    return PropertyListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Property.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

class SearchFilters {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final double? minArea;
  final double? maxArea;

  SearchFilters({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minArea,
    this.maxArea,
  });

  Map<String, dynamic> toJson() {
    return {
      if (city != null) 'city': city,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minBedrooms != null) 'bedrooms': minBedrooms,
      if (minArea != null) 'min_area': minArea,
      if (maxArea != null) 'max_area': maxArea,
    };
  }

  SearchFilters copyWith({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    double? minArea,
    double? maxArea,
  }) {
    return SearchFilters(
      city: city ?? this.city,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
    );
  }
}
