import 'package:flutter/material.dart';
import '../screens/AddProductScreen.dart';
import '../services/product.dart';
import '../services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'details_screen.dart';
import 'dart:io';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  InventoryScreenState createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cargar productos desde la base de datos local
  void _loadProducts() async {
    List<Product> products = await _storageService.getProducts();
    setState(() {
      _products = products;
      _applyFilter(); //En caso de que haya un filtro aplicado, se aplica a los productos cargados
    });
  }

  // Mostrar cuadro de diálogo de confirmación antes de eliminar un producto
  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirmar Eliminación',
            style: GoogleFonts.lato(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2C2C2C),
          content: Text(
            '¿Estás seguro de que deseas eliminar este producto?',
            style: GoogleFonts.lato(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                try {
                  Navigator.pop(context); // Cerrar el diálogo
                  _deleteProduct(id); // Eliminar el producto

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto Eliminado correctamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al Eliminar el producto'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Eliminar',
                style: GoogleFonts.lato(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Eliminar un producto
  void _deleteProduct(int id) async {
    await _storageService.deleteProduct(id);
    _loadProducts(); // Recargar productos
  }

  // Filtrar productos según el texto de búsqueda
  void _filterProducts() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(searchText);
      }).toList();
    });
  }

  // Método para construir los botones de filtrado
  Widget _buildFilterButton(String label, int filter) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedFilter = filter;
            _applyFilter();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedFilter == filter
              ? Color(0xFF0B5DAE)
              : Colors.transparent,
          side: BorderSide(
            color: Color(0xFF0B5DAE),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: _selectedFilter == filter ? Colors.white : Color(0xFF0B5DAE),
          ),
        ),
      ),
    );
  }

  // Método para aplicar el filtro rapido
  void _applyFilter() {
    setState(() {
      switch (_selectedFilter) {
        case 0: // Todos
          _filteredProducts = _products;
          break;
        case 1: // En Stock
          _filteredProducts = _products
              .where((product) => product.quantity > product.minquantity)
              .toList();
          break;
        case 2: // Bajo Stock
          _filteredProducts = _products
              .where((product) => product.quantity <= product.minquantity)
              .toList();
          break;
        case 3: // Sin Stock
          _filteredProducts =
              _products.where((product) => product.quantity == 0).toList();
          break;
        default:
          _filteredProducts = _products;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      appBar: AppBar(
        title: Text('Inventario', style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Color(0xFF0B5DAE),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  products: _products,
                  onDeleteProduct: (id) {
                    _deleteProduct(id);
                  },
                  onLoadProducts: () {
                    _loadProducts();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('Todos', 0),
                    _buildFilterButton('En Stock', 1),
                    _buildFilterButton('Bajo Stock', 2),
                    _buildFilterButton('Sin Stock', 3),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        _selectedFilter == 1
                            ? 'No hay productos en stock.'
                            : _selectedFilter == 2
                                ? 'No hay productos en bajo stock.'
                                : _selectedFilter == 3
                                    ? 'No hay productos sin stock.'
                                    : 'No hay productos en el inventario.',
                        style:
                            GoogleFonts.lato(fontSize: 18, color: Colors.white),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadProducts(); // Recargar los productos
                      },
                      child: ListView.builder(
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final isOutOfStock = product.quantity == 0;
                          final isLowStock =
                              product.quantity <= product.minquantity;
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            color: isOutOfStock
                                ? const Color.fromARGB(255, 53, 31, 31)
                                : const Color.fromARGB(255, 64, 64, 64),
                            child: ListTile(
                              leading: product.imageUrl.startsWith(
                                      'assets/images/default_image.jpg')
                                  ? Image.asset(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error,
                                            color: Colors
                                                .red); // Manejo de errores
                                      },
                                    )
                                  : Image.file(
                                      File(product.imageUrl),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error,
                                            color: Colors
                                                .red); // Manejo de errores
                                      },
                                    ),
                              title: Row(
                                children: [
                                  if (isOutOfStock || isLowStock)
                                    const Icon(Icons.warning,
                                        color: Colors.amber, size: 20),
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: TextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Cant: ${product.quantity} | Precio: \$${product.price}',
                                style:
                                    GoogleFonts.lato(color: Colors.grey[300]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color.fromARGB(255, 255, 0, 0)),
                                onPressed: () => _showDeleteConfirmationDialog(
                                    product
                                        .id!), // Mostrar diálogo de confirmación
                              ),
                              onTap: () {
                                // Navegar a la pantalla de detalles del producto
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                        product: product,
                                        onProductDeleted: (deletedProduct) {
                                          _deleteProduct(deletedProduct.id!);
                                          _loadProducts();
                                        }),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la pantalla de agregar producto
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
          // Recargar productos después agregar uno nuevo
          _loadProducts();
        },
        backgroundColor: Color.fromARGB(255, 14, 90, 0),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  final Function(int) onDeleteProduct; // Callback para eliminar un producto
  final Function() onLoadProducts; // Callback para recargar productos

  ProductSearchDelegate({
    required this.products,
    required this.onDeleteProduct,
    required this.onLoadProducts,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark, // Modo oscuro
      scaffoldBackgroundColor: Color.fromARGB(255, 32, 32, 32),
      appBarTheme: AppBarTheme(
        backgroundColor:
            Color.fromARGB(255, 32, 32, 32), // Color de la barra de búsqueda
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.lato(color: Colors.white, fontSize: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.fromARGB(255, 50, 50, 50),
        hintStyle: GoogleFonts.lato(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      color: Colors.white,
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          leading:
              product.imageUrl.startsWith('assets/images/default_image.jpg')
                  ? Image.asset(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            color: Colors.red); // Manejo de errores
                      },
                    )
                  : Image.file(
                      File(product.imageUrl),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            color: Colors.red); // Manejo de errores
                      },
                    ),
          title: Text(product.name),
          onTap: () {
            close(context, ""); // Cierra la búsqueda
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: product,
                  onProductDeleted: (deletedProduct) {
                    // Lógica para manejar la eliminación del producto
                    if (deletedProduct.id != null) {
                      onDeleteProduct(
                          deletedProduct.id!); // Eliminar el producto
                      onLoadProducts(); // Recargar la lista de productos
                    } else {
                      // Manejar el caso en que deletedProduct.id sea null
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: El ID del producto es nulo.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          leading:
              product.imageUrl.startsWith('assets/images/default_image.jpg')
                  ? Image.asset(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            color: Colors.red); // Manejo de errores
                      },
                    )
                  : Image.file(
                      File(product.imageUrl),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            color: Colors.red); // Manejo de errores
                      },
                    ),
          title: Text(product.name),
          onTap: () {
            close(context, ""); // Cierra la búsqueda
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: product,
                  onProductDeleted: (deletedProduct) {
                    if (deletedProduct.id != null) {
                      onDeleteProduct(
                          deletedProduct.id!); // Eliminar el producto
                      onLoadProducts(); // Recargar la lista de productos
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: El ID del producto es nulo.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
