import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/local_storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/product.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minquantityController;
  late TextEditingController _priceController;
  File? _image;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _minquantityController =
        TextEditingController(text: widget.product.minquantity.toString());
    _priceController =
        TextEditingController(text: widget.product.price.toString());
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        title: Text(
          'Editar Producto',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF0B5DAE),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isPickingImage ? null : _pickImage,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey[800]),
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
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: GoogleFonts.lato(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              controller: _nameController,
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: GoogleFonts.lato(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                    ),
                    style:
                        GoogleFonts.lato(color: Colors.white70, fontSize: 20),
                  ),
                ),
                SizedBox(width: 25),
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
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minquantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad mínima',
                      labelStyle: GoogleFonts.lato(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70)),
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
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Precio',
                labelStyle: GoogleFonts.lato(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
              controller: _priceController,
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 20),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar sin guardar cambios
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
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Crear el producto actualizado
                    final updatedProduct = Product(
                      id: widget.product.id, // Mantener el mismo ID
                      name: _nameController.text,
                      quantity: int.parse(_quantityController.text),
                      minquantity: int.parse(_minquantityController.text),
                      price: double.parse(_priceController.text),
                      imageUrl: _image?.path ?? widget.product.imageUrl,
                    );

                    // Actualizar el producto en la base de datos
                    final localStorageService = LocalStorageService();
                    await localStorageService.updateProduct(updatedProduct);

                    // Devolver el producto actualizado a la pantalla anterior
                    Navigator.of(context).pop(updatedProduct);
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
                    'Confirmar',
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
}
