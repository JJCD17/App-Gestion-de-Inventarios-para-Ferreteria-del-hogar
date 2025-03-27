import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/product.dart';
import '../services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minquantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addProduct() async {
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
            style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 11, 93, 174),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization
                  .words, // Hace que cada palabra comience con mayúscula
              style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 200,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
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
                Container(
                  width: 200,
                  child: TextField(
                    controller: _minquantityController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad minima',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
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
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(
                labelText: 'Precio',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, color: Colors.red);
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey[800],
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Añadir imagen',
                                    style: GoogleFonts.lato(
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar',
                        style: GoogleFonts.lato(
                            color: Color.fromARGB(255, 255, 1, 1),
                            fontSize: 24)),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: _addProduct,
                    child: Text('Agregar',
                        style: GoogleFonts.lato(
                            color: Color.fromARGB(255, 0, 255, 0),
                            fontSize: 24)),
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
