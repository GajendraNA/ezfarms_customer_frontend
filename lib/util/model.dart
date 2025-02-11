class User {
  int id;
  String name;
  String email;
  String password;
  String address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
  });

  // Factory constructor for creating a new User instance from a map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      address: json['address'],
    );
  }

  // Method to convert a User instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
    };
  }
}

class Inventory {
  final String name;
  final int id;
  final int farmerId;
  final double weight;
  final double remainingWeight;
  final double finalRatePerKg;
  final String farmerName;
  final String itemName;
  final String itemDescription;
  final String itemCategory;

  Inventory({
    required this.name,
    required this.id,
    required this.farmerId,
    required this.weight,
    required this.remainingWeight,
    required this.finalRatePerKg,
    required this.farmerName,
    required this.itemName,
    required this.itemDescription,
    required this.itemCategory,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      name: json['name'],
      id: json['id'],
      farmerId: json['farmer_id'],
      weight: json['weight'],
      remainingWeight: json['remaining_weight'],
      finalRatePerKg: json['final_rate_per_kg'],
      farmerName: json['farmer_name'],
      itemName: json['item_name'],
      itemDescription: json['item_description'],
      itemCategory: json['item_category'],
    );
  }
}

