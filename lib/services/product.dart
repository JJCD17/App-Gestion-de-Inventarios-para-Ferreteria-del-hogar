class Product {
  final int? id;
  final String name;
  int quantity;
  int minquantity;
  final double price;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    required this.quantity,
    required this.minquantity,
    required this.price,
    required this.imageUrl,
  });

  // Convertir el objeto Product a un Map para almacenar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'minquantity': minquantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Convertir un Map a un objeto Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      minquantity: map['minquantity'] ?? 0,
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }
}
