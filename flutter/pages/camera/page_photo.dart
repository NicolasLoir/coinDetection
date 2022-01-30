import 'dart:io';

import 'package:coco/utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:crypto/crypto.dart' as crypto;

class Photo extends StatefulWidget {
  const Photo({Key? key}) : super(key: key);

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  File? image;
  bool _envoieEnCours = false;
  String? _pathImage;
  late String _ipServeur;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        _pathImage = image.path;
      });
    } on PlatformException catch (e) {
      print("Failed to pick image $e");
    }
  }

  doUpload() {
    SharedPref.getIp().then((value) {
      _ipServeur = value;
      SharedPref.getUuid().then((cuid) {
        setState(() {
          _envoieEnCours = true;
        });
        var md5 = crypto.md5;
        var hash = md5.bind(File(_pathImage!).openRead()).first.then((hash) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                _ipServeur + "uploadPhoto/" + cuid + '/' + hash.toString()),
          );
          Map<String, String> headers = {"Content-type": "multipart/form-data"};
          request.files.add(
            http.MultipartFile(
              'image',
              image!.readAsBytes().asStream(),
              image!.lengthSync(),
              filename: "filename",
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          request.headers.addAll(headers);
          request.send().then((value) {
            setState(() {
              _envoieEnCours = false;
            });
            if (value.statusCode == 201) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text("La photo s'est correctement envoyé"),
                duration: Duration(seconds: 2),
              ));
              setState(() {
                image = null;
              });
            } else if (value.statusCode == 403) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text("Erreur de formatage md5."),
                duration: Duration(seconds: 2),
              ));
            } else {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Erreur lors de l'envoi ou du traitement de la photo."),
                duration: Duration(seconds: 2),
              ));
            }
            print(value.statusCode);
          });
        }).onError((error, stackTrace) {
          setState(() {
            _envoieEnCours = false;
          });
          Scaffold.of(context).showSnackBar(const SnackBar(
            content:
                Text("Erreur lors de l'envoi ou du traitement de la photo."),
            duration: Duration(seconds: 2),
          ));
        });
      }).catchError((error) {
        Scaffold.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors du chargement des données du profil'),
          duration: Duration(seconds: 2),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(),
            image == null
                ? const Center(
                    child: Image(
                      image: AssetImage('images/Logo_COCO.jpg'),
                      width: 300.0,
                    ),
                  )
                : Image.file(
                    image!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
            if (_envoieEnCours) buildChargement() else buildInterface(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildInterface() => Column(
        children: [
          const SizedBox(height: 70),
          buildButton(
            title: "Choisir une photo",
            icon: Icons.image_outlined,
            onClicked: () => pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 24),
          buildButton(
            title: "Prendre une photo",
            icon: Icons.camera_alt_outlined,
            onClicked: () => pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 70),
          if (image != null)
            buildButton(
              title: "Envoyer la photo au serveur",
              icon: Icons.send,
              onClicked: () => doUpload(),
            ),
        ],
      );

  Widget buildChargement() => Column(
        children: [
          const SizedBox(height: 70),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Envoi et traitement de la photo en cours",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );

  Widget buildButton(
          {required String title,
          required IconData icon,
          required VoidCallback onClicked}) =>
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          primary: Colors.white,
          onPrimary: Colors.black,
          textStyle: const TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(title)
          ],
        ),
      );
}
