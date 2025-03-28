import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/product.dart';

class LocalStorageService {
  static Database? _database;

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  _initDatabase() async {
    var dbPath = await getDatabasesPath();
    var path = join(dbPath, 'inventory.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          quantity INTEGER,
          minquantity INTEGER,
          price REAL,
          imageUrl TEXT
        )
      ''');
    });
  }

  // Guardar un producto en la base de datos local
  Future<void> saveProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Reemplazar si el producto ya existe
    );
  }

  // Obtener todos los productos desde la base de datos
  Future<List<Product>> getProducts() async {
    final db = await database;
    var result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  // Actualizar un producto en la base de datos
  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Eliminar un producto de la base de datos
  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
