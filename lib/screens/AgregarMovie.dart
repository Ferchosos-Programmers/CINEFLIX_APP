import 'package:cineflix/screens/MovieGallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(AgregarMovie());
}

class AgregarMovie extends StatelessWidget {
  const AgregarMovie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agregar Movie',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/gallery': (context) => MovieGallery(),
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _imageLinkController =
      TextEditingController(); // Nuevo controlador para la URL de la imagen

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _imageLink;

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _videoLinkController.dispose();
    _imageLinkController
        .dispose(); // Dispose del controlador de la URL de la imagen
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageLink =
            null; // Resetear la URL de la imagen si se selecciona una nueva imagen desde la galería
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      final fileName = _imageFile!.path.split('/').last;
      final storageRef =
          FirebaseStorage.instance.ref().child('movie_images/$fileName');
      final uploadTask = storageRef.putFile(_imageFile!);

      final taskSnapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _imageLink = downloadUrl;
      });
    }
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && _imageLinkController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please pick an image or enter an image URL')),
        );
        return;
      }

      if (_imageFile != null) {
        await _uploadImage();
      }

      final String title = _titleController.text;
      final String director = _directorController.text;
      final String genre = _genreController.text;
      final int year = int.parse(_yearController.text);
      final String videoLink = _videoLinkController.text;
      final String imageLink = _imageLink ??
          _imageLinkController
              .text; // Usar la URL ingresada si no se seleccionó una imagen

      // Add movie to Firestore
      await FirebaseFirestore.instance.collection('movies').add({
        'title': title,
        'director': director,
        'genre': genre,
        'year': year,
        'videoLink': videoLink,
        'imageLink': imageLink,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movie added successfully!')),
      );

      _titleController.clear();
      _directorController.clear();
      _genreController.clear();
      _yearController.clear();
      _videoLinkController.clear();
      _imageLinkController.clear();
      setState(() {
        _imageFile = null;
        _imageLink = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Película'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _directorController,
                decoration: InputDecoration(labelText: 'Director'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce un director';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(labelText: 'Género'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce un género';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Año de publicación'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce un año de publicación';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor introduce un año de publicación válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _videoLinkController,
                decoration: InputDecoration(labelText: 'Enlace de Video'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un enlace de video';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: _pickImage,
              //   child: Text('Seleccionar Imagen'),
              // ),
              // if (_imageFile != null) ...[
              //   SizedBox(height: 10),
              //   Image.file(_imageFile!, height: 150),
              // ],
              // SizedBox(height: 10),
              TextFormField(
                controller: _imageLinkController,
                decoration: InputDecoration(labelText: 'Ingrese URL de Imagen'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gallery');
                },
                child: Text('Ver Galería'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMovie,
                child: Text('Guardar Película'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
