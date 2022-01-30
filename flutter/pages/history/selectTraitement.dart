// ignore_for_file: file_names

import 'package:coco/modeles/traitement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectTraitement extends StatefulWidget {
  Traitement _traitement;
  String _ipServeur;
  SelectTraitement(this._traitement, this._ipServeur, {Key? key})
      : super(key: key);

  @override
  _SelectTraitementState createState() => _SelectTraitementState();
}

class _SelectTraitementState extends State<SelectTraitement> {
  bool _envoieEnCours = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selectionner une photo"),
      ),
      body: resultatPhoto(),
    );
  }

  Widget resultatPhoto() {
    return ListView(
      children: [
        Image.network(
            widget._ipServeur + widget._traitement.urlPhoto! + "_medium"),
        cardTitle("Concernant cette photo..."),
        cardOption(
            "Total", (widget._traitement.total! / 100).toString() + " €"),
        cardOption(
          "Note",
          widget._traitement.estAnalyse!
              ? widget._traitement.note!.toString() + " /5"
              : "Pas de note",
        ),
        cardOption("Date", widget._traitement.datePhoto!),
        cardTitle("Action:"),
        _envoieEnCours
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              )
            : cardOptionWithFunction("Choisir cette photo", "", () {
                setState(() {
                  _envoieEnCours = true;
                });
                http
                    .post(
                  Uri.parse(
                    widget._ipServeur +
                        'definirPhoto/' +
                        widget._traitement.idTraitement!.toString(),
                  ),
                )
                    .then((value) {
                  Navigator.of(context).pop();
                }).onError((error, stackTrace) {
                  print(error);
                });
              })
      ],
    );
  }

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

  Widget cardOption(String title, String sousTitre) {
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
        trailing:
            Text(sousTitre, style: TextStyle(color: Colors.grey.shade700)),
      ),
    );
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
}
