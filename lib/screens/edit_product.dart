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
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
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
      backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      appBar: AppBar(
        title: Text(
          'Editar Producto',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 93, 174),
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
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Stack(
                  children: [
                    // Muestra la imagen actual del producto si existe, o la nueva imagen seleccionada
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          _image != null
                              ? Image.file(
                                  _image!,
                                  width: 230,
                                  height: 230,
                                  fit: BoxFit.cover,
                                )
                              : (widget.product.imageUrl.isNotEmpty &&
                                      File(widget.product.imageUrl)
                                          .existsSync())
                                  ? Image.file(File(widget.product.imageUrl),
                                      width: 230,
                                      height: 230,
                                      fit: BoxFit.cover)
                                  : Container(
                                      color: Colors
                                          .grey[300]), // Imagen predeterminada
                          Container(
                            width: 230,
                            height: 230,
                            color: Colors.black
                                .withValues(alpha: 0.4), // Difuminado
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              color: Colors.white, size: 30),
                          SizedBox(height: 5),
                          Text(
                            'Cambiar imagen',
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
                    try {
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

                      // Mostrar notificación de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Producto actualizado correctamente'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Devolver el producto actualizado a la pantalla anterior
                      Navigator.of(context).pop(updatedProduct);
                    } catch (e) {
                      // Mostrar notificación de error si algo falla
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar el producto'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
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
