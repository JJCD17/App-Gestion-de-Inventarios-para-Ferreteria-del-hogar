import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product.dart';
import 'EditProductScreen.dart';
import '../services/local_storage_service.dart';
import 'dart:io';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onProductDeleted; // Callback eliminación

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onProductDeleted,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product product;

  @override
  void initState() {
    super.initState();
    product = widget.product; // Inicializar el producto con el valor pasado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      appBar: AppBar(
        title: Text(
          'Detalles del Producto',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 93, 174),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: product.imageUrl
                        .startsWith('assets/images/default_image.jpg')
                    ? Image.asset(
                        product.imageUrl,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              color: Colors.red, size: 50);
                        },
                      )
                    : Image.file(
                        File(product.imageUrl),
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              color: Colors.red, size: 50);
                        },
                      ),
              ),
            ),
            // Leyenda "Sin Stock" condicional
            if (product.quantity == 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Sin Stock',
                  style: GoogleFonts.lato(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (product.quantity <= product.minquantity &&
                product.quantity != 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Bajo Stock',
                  style: GoogleFonts.lato(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              color: const Color.fromARGB(255, 44, 44, 44),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nombre:', product.name),
                    const Divider(color: Colors.white30),
                    _buildDetailRow(
                        'Cantidad actual:', product.quantity.toString()),
                    const Divider(color: Colors.white30),
                    _buildDetailRow(
                        'Cantidad minima:', product.minquantity.toString()),
                    const Divider(color: Colors.white30),
                    _buildDetailRow('Precio:', '\$${product.price}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _showDeleteConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Eliminar',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Crear una instancia de LocalStorageService
                    LocalStorageService localStorageService =
                        LocalStorageService();

                    // Actualizar la cantidad a 0 en el producto
                    product.quantity = 0;

                    // Actualizar el producto en la base de datos
                    await localStorageService.updateProduct(product);

                    // Actualizar el estado local
                    setState(() {
                      product.quantity = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Sin Stock',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Navegar a la pantalla de edición y esperar el resultado
                    final updatedProduct = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProductScreen(product: product),
                      ),
                    );

                    // Si el producto fue actualizado, actualiza el estado
                    if (updatedProduct != null) {
                      setState(() {
                        product = updatedProduct; // Actualizar el producto
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Editar',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación',
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 44, 44, 44),
          content: Text('¿Estás seguro de que deseas eliminar este producto?',
              style: GoogleFonts.lato(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar',
                  style: GoogleFonts.lato(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                try {
                  widget.onProductDeleted(product);
                  Navigator.of(context).pop(); // Cierra el diálogo
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior
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
              child:
                  Text('Eliminar', style: GoogleFonts.lato(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
