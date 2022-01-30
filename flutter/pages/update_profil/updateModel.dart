// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateModel extends StatefulWidget {
  Utilisateur _user;
  String ipAdress;

  UpdateModel(this._user, this.ipAdress, {Key? key}) : super(key: key);

  @override
  _UpdateModelState createState() => _UpdateModelState();
}

class _UpdateModelState extends State<UpdateModel> {
  String? _modelSelected;
  String _messageErreur = '';
  Map<String, int> _modelMap = {
    '': 0,
  };
  bool _boutonVisible = false;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    http
        .post(
      Uri.parse(widget.ipAdress + 'getListModelForUser/' + widget._user.cuid!),
    )
        .then((value) {
      final data = jsonDecode(value.body);
      Map<String, int> newModelMap = {};
      for (final name in data.keys) {
        int id = data[name];
        newModelMap[name] = id;
      }
      setState(() {
        _modelMap = newModelMap;
        _modelSelected = _modelMap.keys.first;
        _boutonVisible = true;
        _messageErreur = '';
      });
      // print(data);
    }).catchError((error) {
      print("erreur getListModelForUser");
      print(error);
      setState(() {
        _messageErreur =
            "Une erreur est survenu côté serveur. Veuillez réessayer plus tard.";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reconnaitre une pièce"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          messageInstruction(),
          const SizedBox(height: 10),
          buildModel(),
          const SizedBox(height: 30),
          if (_boutonVisible)
            _envoiEnCours
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  )
                : boutonValider(),
          messageErreur(),
        ],
      ),
    );
  }

  Widget buildModel() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _modelSelected,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 50,
          elevation: 16,
          style: const TextStyle(color: Colors.black, fontSize: 20),
          underline: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _modelSelected = newValue;
            });
          },
          items: _modelMap.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );

  Widget boutonValider() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 22),
          primary: Theme.of(context).colorScheme.primary,
          onPrimary: Colors.white,
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary), //  Work!
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.0),
              side: const BorderSide(width: 3)),
        ),
        child: const Text('Mettre à jour'),
        onPressed: () {
          setState(() {
            _envoiEnCours = true;
          });
          int? idModel = _modelMap[_modelSelected];
          http
              .post(
            Uri.parse(widget.ipAdress +
                'updateModelForUser/' +
                widget._user.cuid! +
                '/' +
                idModel.toString()),
          )
              .then((value) {
            _messageErreur = '';
            Navigator.of(context).pop();
            widget._user.nameModelFavori = _modelSelected;
            widget._user.idModelFavori = idModel;
          }).onError((error, stackTrace) {
            print("erreur http updateModel");
            print(error);
            setState(() {
              _envoiEnCours = false;
              _messageErreur =
                  "Une erreur est survenu côté serveur. Veuillez réessayer plus tard.";
            });
          });
        },
      );

  Widget messageErreur() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          _messageErreur,
          style: const TextStyle(color: Colors.red),
        ),
      );

  Widget messageInstruction() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Veuillez choisir parmi la liste deroulante la méthode permettant de reconnaitre les pièces sur une photo.",
          style: TextStyle(color: Colors.black),
        ),
      );
}
