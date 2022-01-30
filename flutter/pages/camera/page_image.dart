import 'dart:io';
import 'package:flutter/material.dart';

class PageImage extends StatefulWidget {
  final String nomFichierImage;
  const PageImage(this.nomFichierImage, {Key? key}) : super(key: key);

  @override
  _PageImageState createState() => _PageImageState();
}

class _PageImageState extends State<PageImage> {
  @override
  Widget build(BuildContext context) {
    print("abcdef page_image " + widget.nomFichierImage);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauvegarder la photo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              print("photo savveed");
              // MaterialPageRoute route = MaterialPageRoute(
              //     builder: (context) => const PagePrincipale());
              // Navigator.push(context, route);
            },
          ),
        ],
      ),
      body: Image.file(File(widget.nomFichierImage)),
    );
  }
}
