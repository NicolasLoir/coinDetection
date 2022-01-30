// ignore_for_file: file_names

import 'dart:ffi';

import 'package:coco/modeles/traitement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteTraitement extends StatefulWidget {
  Traitement traitement;
  String _ipServeur;
  NoteTraitement(this.traitement, this._ipServeur, {Key? key})
      : super(key: key);

  @override
  _NoteTraitementState createState() => _NoteTraitementState();
}

class _NoteTraitementState extends State<NoteTraitement> {
  bool _donneCharge = false;
  final List<int> _listValeurAnalyses = [];
  final List<String> _listIdPieces = [];
  int _currentPiece = 0;
  late String _currentUrlPhoto;
  late String _valeurCurentPiece;
  bool _pieceBonneValeur = true;
  bool _estUnePiece = true;
  bool _deuxiemeCardVisible = false;
  String _sortSelected = '5 centimes';
  bool _analyseTermine = false;
  final Map<String, int> _modelMap = {
    '5 centimes': 5,
    '10 centimes': 10,
    '20 centimes': 20,
    '50 centimes': 50,
    '1 euro': 100,
    '2 euros': 200,
  };
  String _msgButtonValidate = "Pièce suivante";
  bool _envoieEnCours = false;

  @override
  void initState() {
    super.initState();
    initNotePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noter une photo"),
      ),
      body: RefreshIndicator(
        child: SafeArea(
          child: maPageNote(),
        ),
        onRefresh: () {
          return initNotePage();
        },
      ),
    );
  }

  Widget maPageNote() {
    if (_donneCharge) {
      return ListView(
        children: [
          Image.network(_currentUrlPhoto),
          cardTitle("Concernant cette pièce, est-ce ..."),
          cardOption(
            "une piece de " + _valeurCurentPiece + " ?",
            Switch(
              value: _pieceBonneValeur,
              onChanged: (value) {
                setState(() {
                  _pieceBonneValeur = value;
                  _deuxiemeCardVisible = !_pieceBonneValeur;
                });
              },
              activeTrackColor: Theme.of(context).colorScheme.secondaryVariant,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (_deuxiemeCardVisible)
            cardOption(
              "une piece de monnaie ?",
              Switch(
                value: _estUnePiece,
                onChanged: (value) {
                  setState(() {
                    _estUnePiece = value;
                  });
                },
                activeTrackColor:
                    Theme.of(context).colorScheme.secondaryVariant,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (_deuxiemeCardVisible && _estUnePiece)
            cardTitle("Selectionner sa valeur monétaire:"),
          if (_deuxiemeCardVisible && _estUnePiece) buildDropDownList(),
          _envoieEnCours
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                )
              : cardOptionWithFunction(_msgButtonValidate, "", () {
                  setState(() {
                    _envoieEnCours = true;
                  });
                  bool envoieEncours = false;
                  if (_msgButtonValidate == "Terminer l'analyse") {
                    envoieEncours = true;
                    updatePieceBDD(envoieEncours, () => updateTraitementBDD());
                  } else {
                    updatePieceBDD(envoieEncours, () {});
                    setState(() {
                      _currentPiece += 1;
                    });
                  }
                }),
        ],
      );
    } else {
      return ListView(
        children: [
          const SizedBox(
            height: 200,
          ),
          Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
        physics: const AlwaysScrollableScrollPhysics(),
      );
    }
  }

  void updateTraitementBDD() {
    String idPiece = _listIdPieces[_currentPiece];
    http
        .post(
      Uri.parse(
        widget._ipServeur +
            '/updateTotalAndNoteTraitement/' +
            widget.traitement.idTraitement.toString(),
      ),
    )
        .then((value) {
      if (value.statusCode == 201) {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  void updatePieceBDD(bool envoieEnCours, Function ifSuccess) {
    String idPiece = _listIdPieces[_currentPiece];
    String estPiece = _estUnePiece ? '1' : '0';
    String valuePiece = _modelMap[_sortSelected].toString();
    String pieceBonneValeur = _pieceBonneValeur ? '1' : '0';
    http
        .post(
      Uri.parse(
        widget._ipServeur +
            '/updateValuePiece/' +
            idPiece +
            '/' +
            estPiece +
            '/' +
            valuePiece +
            '/' +
            pieceBonneValeur,
      ),
    )
        .then((value) {
      if (value.statusCode == 201) {
        setState(() {
          _estUnePiece = true;
          _pieceBonneValeur = true;
          _envoieEnCours = envoieEnCours;
          _deuxiemeCardVisible = false;
          updatePiece();
        });
        ifSuccess();
      }
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  Widget cardOptionWithFunction(
      String title, String sousTitre, Function functionOnTap) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.all(0),
      color: Theme.of(context).primaryColor,
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Text(sousTitre,
            style: TextStyle(color: Theme.of(context).primaryColor)),
        onTap: () {
          functionOnTap();
        },
      ),
    );
  }

  Widget buildDropDownList() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _sortSelected,
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
              _sortSelected = newValue!;
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

  Widget cardTitle(String title) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.all(0),
      color: Colors.grey.shade300,
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget cardOption(String title, Widget trailingWidget) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.all(0),
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        trailing: trailingWidget,
      ),
    );
  }

  Future<void> initNotePage() {
    return http
        .post(
      Uri.parse(widget._ipServeur +
          'getAllPiece/' +
          widget.traitement.idTraitement.toString()),
    )
        .then((response) {
      if (response.statusCode == 201) {
        // print(response.body);
        Map<String, dynamic> mapJson = json.decode(response.body);
        for (final name in mapJson.keys) {
          final value = mapJson[name];
          // print('$name,$value');
          _listIdPieces.add(value["id_piece"].toString());
          _listValeurAnalyses.add(value["valeur_analyse"]);
        }

        setState(() {
          _donneCharge = true;
          updatePiece();
        });
      } else {
        print(response.statusCode);
      }
    }).catchError((onError, stackTrace) {
      print(onError);
    });
  }

  void updatePiece() {
    _analyseTermine = _currentPiece == _listIdPieces.length - 1;
    if (_analyseTermine) {
      _msgButtonValidate = "Terminer l'analyse";
    }
    _currentUrlPhoto =
        widget._ipServeur + 'getPhotoPiece/' + _listIdPieces[_currentPiece];
    int valeurAnalyse = _listValeurAnalyses[_currentPiece];
    _valeurCurentPiece = valeurAnalyse == 200
        ? '2 euros'
        : valeurAnalyse == 100
            ? '1 euro'
            : valeurAnalyse.toString() + ' centimes';
  }
}
