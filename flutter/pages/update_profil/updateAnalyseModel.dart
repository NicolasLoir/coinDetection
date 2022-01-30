// ignore_for_file: file_names

import 'package:coco/modeles/traitement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateAnalyseModel extends StatefulWidget {
  Traitement _traitement;
  String _ipServeur;

  UpdateAnalyseModel(this._traitement, this._ipServeur, {Key? key})
      : super(key: key);

  @override
  _UpdateAnalyseModelState createState() => _UpdateAnalyseModelState();
}

class _UpdateAnalyseModelState extends State<UpdateAnalyseModel> {
  String? _modelSelected;
  String _messageErreur = '';
  bool _envoieEnCours = false;
  Map<String, int> _modelMap = {
    '': 0,
  };
  String? _analyseSelected;
  Map<String, int> _analyseMap = {
    '': 0,
  };
  bool _boutonVisible = false;

  @override
  void initState() {
    super.initState();
    http
        .post(
      Uri.parse(widget._ipServeur +
          'getListModelForTraitement/' +
          widget._traitement.nameModel!),
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
      });

      http
          .post(
        Uri.parse(widget._ipServeur +
            'getListAnalyseForTraitement/' +
            widget._traitement.nameAnalyse!),
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
        title: const Text("Reconnaitre une pièce"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          messageInstructionAnalyse(),
          const SizedBox(height: 10),
          buildAnalyse(),
          const SizedBox(height: 10),
          messageInstructionModel(),
          const SizedBox(height: 10),
          buildModel(),
          const SizedBox(height: 30),
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
            _envoieEnCours = true;
          });
          int? idModel = _modelMap[_modelSelected];
          int? idAnalyse = _analyseMap[_analyseSelected];
          http
              .post(Uri.parse(widget._ipServeur +
                  'updateTraitement/' +
                  widget._traitement.idTraitement!.toString() +
                  '/' +
                  idAnalyse.toString() +
                  '/' +
                  idModel.toString()))
              .then((value) {
            _messageErreur = '';
            Navigator.of(context).pop();
            widget._traitement.nameModel = _modelSelected;
            widget._traitement.nameAnalyse = _analyseSelected;
          }).onError((error, stackTrace) {
            _envoieEnCours = false;
            print("erreur http updateModel");
            print(error);
            setState(() {
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

  Widget messageInstructionModel() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Veuillez choisir parmi la liste deroulante la méthode permettant de reconnaitre les pièces sur la photo.",
          style: TextStyle(color: Colors.black),
        ),
      );

  Widget messageInstructionAnalyse() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Veuillez choisir parmi la liste deroulante la méthode permettant de localiser les pièces sur la photo.",
          style: TextStyle(color: Colors.black),
        ),
      );
}
