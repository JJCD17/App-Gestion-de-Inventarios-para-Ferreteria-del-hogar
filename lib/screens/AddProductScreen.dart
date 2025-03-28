import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/product.dart';
import '../services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
  });

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minquantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addProduct() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto añadido correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      if (_nameController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty &&
          _minquantityController.text.isNotEmpty &&
          _priceController.text.isNotEmpty) {
        Product newProduct = Product(
          name: _nameController.text,
          quantity: int.parse(_quantityController.text),
          minquantity: int.parse(_minquantityController.text),
          price: double.parse(_priceController.text),
          imageUrl: _selectedImage?.path ?? 'assets/images/default_image.jpg',
        );
        await _storageService.saveProduct(newProduct);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showErrorDialog('Por favor, complete todos los campos.');
      }
    } catch (e) {
      // Mostrar notificación de error si algo falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir el producto'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: GoogleFonts.lato(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 44, 44, 44),
          content: Text(
            message,
            style: GoogleFonts.lato(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Aceptar',
                style: GoogleFonts.lato(color: Colors.deepPurpleAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      appBar: AppBar(
        title: Text('Agregar Producto',
            style: GoogleFonts.lato(color: Colors.white, fontSize: 22)),
        backgroundColor: const Color.fromARGB(255, 11, 93, 174),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: GoogleFonts.lato(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              controller: _nameController,
              textCapitalization: TextCapitalization
                  .words, // Hace que cada palabra comience con mayúscula
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: GoogleFonts.lato(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                    ),
                    style:
                        GoogleFonts.lato(color: Colors.white70, fontSize: 20),
                  ),
                ),
                SizedBox(width: 30),
                Material(
                  color: const Color.fromARGB(255, 11, 93, 174),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: Icon(Icons.remove, color: Colors.white70),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(_quantityController.text) ?? 0;
                      if (currentValue > 0) {
                        _quantityController.text =
                            (currentValue - 1).toString();
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Material(
                  color: const Color.fromARGB(255, 11, 93, 174),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.white70),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(_quantityController.text) ?? 0;
                      _quantityController.text = (currentValue + 1).toString();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _minquantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad minima',
                      labelStyle: GoogleFonts.lato(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                    ),
                    style:
                        GoogleFonts.lato(color: Colors.white70, fontSize: 20),
                  ),
                ),
                SizedBox(width: 30),
                Material(
                  color: const Color.fromARGB(255, 11, 93, 174),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: Icon(Icons.remove, color: Colors.white70),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(_minquantityController.text) ?? 0;
                      if (currentValue > 0) {
                        _minquantityController.text =
                            (currentValue - 1).toString();
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Material(
                  color: const Color.fromARGB(255, 11, 93, 174),
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.white70),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(_minquantityController.text) ?? 0;
                      _minquantityController.text =
                          (currentValue + 1).toString();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Precio',
                labelStyle: GoogleFonts.lato(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              controller: _priceController,
              keyboardType: TextInputType.number,
              textCapitalization: TextCapitalization
                  .words, // Hace que cada palabra comience con mayúscula
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Toca para agregar una imagen',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap:
                      _pickImage, // Llama a la función para seleccionar imagen
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      width: 230,
                                      height: 230,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error,
                                            color: Colors.red);
                                      },
                                    )
                                  : Container(color: Colors.grey[300]),
                              Container(
                                width: 230,
                                height: 230,
                                color: Colors.black
                                    .withValues(alpha: 0.2), // Difuminado
                              ),
                              Positioned.fill(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Colors.white, size: 30),
                                    SizedBox(height: 5),
                                    Text(
                                      'Añadir imagen',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                      'Cancelar',
                      style:
                          GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _addProduct();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Agregar',
                      style:
                          GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
