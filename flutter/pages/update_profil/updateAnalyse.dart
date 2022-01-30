// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateAnalyse extends StatefulWidget {
  Utilisateur _user;
  String _ipAdress;

  UpdateAnalyse(this._user, this._ipAdress, {Key? key}) : super(key: key);

  @override
  _UpdateAnalyseState createState() => _UpdateAnalyseState();
}

class _UpdateAnalyseState extends State<UpdateAnalyse> {
  String? _analyseSelected;
  String _messageErreur = '';
  bool _envoieEnCours = false;
  Map<String, int> _analyseMap = {
    '': 0,
  };
  bool _boutonVisible = false;

  @override
  void initState() {
    super.initState();
    http
        .post(
      Uri.parse(
          widget._ipAdress + 'getListAnalyseForUser/' + widget._user.cuid!),
    )
        .then((value) {
      final data = jsonDecode(value.body);
      Map<String, int> newAnalyseMap = {};
      for (final name in data.keys) {
        int id = data[name];
        newAnalyseMap[name] = id;
      }
      setState(() {
        _analyseMap = newAnalyseMap;
        _analyseSelected = _analyseMap.keys.first;
        _boutonVisible = true;
        _messageErreur = '';
      });
    }).catchError((error) {
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
        title: const Text("Localiser une pièce"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          messageInstruction(),
          const SizedBox(height: 10),
          buildAnalyse(),
          const SizedBox(height: 30),
          if (_boutonVisible)
            _envoieEnCours
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

  Widget buildAnalyse() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _analyseSelected,
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
              _analyseSelected = newValue;
            });
          },
          items: _analyseMap.keys.map<DropdownMenuItem<String>>((String value) {
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
          int? idAnalyse = _analyseMap[_analyseSelected];

          setState(() {
            _envoieEnCours = true;
          });
          http
              .post(
            Uri.parse(widget._ipAdress +
                'updateAnalyseForUser/' +
                widget._user.cuid! +
                '/' +
                idAnalyse.toString()),
          )
              .then((value) {
            _messageErreur = '';
            Navigator.of(context).pop();
            widget._user.nameAnalyseFavori = _analyseSelected;
            widget._user.idAnalyseFavori = idAnalyse;
          }).onError((error, stackTrace) {
            setState(() {
              _envoieEnCours = false;
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
          "Veuillez choisir parmi la liste deroulante la méthode permettant de localiser les pièces sur une photo.",
          style: TextStyle(color: Colors.black),
        ),
      );
}
