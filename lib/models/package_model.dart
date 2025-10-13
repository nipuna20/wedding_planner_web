class PackageModel {
  String? id;
  String name;
  String price;
  String description;

  PackageModel({
    this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'price': price,
      'description': description,
    };

    return data;
  }
}
