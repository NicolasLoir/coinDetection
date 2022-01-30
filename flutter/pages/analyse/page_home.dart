import 'package:coco/modeles/traitement.dart';
import 'package:coco/pages/analyse/noteTraitement.dart';
import 'package:coco/pages/update_profil/updateAnalyseModel.dart';
import 'package:flutter/material.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Traitement _traitement;
  bool _possedePhoto = false;
  bool _donneRecupere = false;
  late String _ipServeur;

  @override
  void initState() {
    super.initState();
    initHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Résultat"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        child: SafeArea(
          child: maHomePage(),
        ),
        onRefresh: () {
          return initHomePage();
        },
      ),
    );
  }

  Widget maHomePage() {
    if (_donneRecupere) {
      return ListView(
        children: [
          if (_possedePhoto) resultatPhoto() else resultatNoPhoto(),
        ],
        physics: const AlwaysScrollableScrollPhysics(),
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

  Widget resultatPhoto() {
    return Column(
      children: [
        Image.network(_ipServeur + _traitement.urlPhoto! + "_medium"),
        cardTitle("Concernant cette photo..."),
        cardOption("Total", (_traitement.total! / 100).toString() + " €"),
        cardOptionWithFunction(
            "Note",
            _traitement.estAnalyse!
                ? _traitement.note!.toString() + "/5"
                : "Noter la photo", () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (_) => NoteTraitement(_traitement, _ipServeur));
          Navigator.push(context, route).then((value) {
            initHomePage();
          });
        }),
        cardOption("Date", _traitement.datePhoto!),
        cardTitle("Modifier les paramètres permettant la..."),
        cardOptionWithFunction(
            "localisation des pièces", _traitement.nameAnalyse!, () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (_) => UpdateAnalyseModel(_traitement, _ipServeur));
          Navigator.push(context, route).then((value) {
            initHomePage();
          }).catchError((error) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Erreur lors de la mise à jour des préférences concernant cette photo'),
              duration: Duration(seconds: 1),
            ));
          });
        }),
        cardOptionWithFunction(
            "reconnaissance des pièces", _traitement.nameModel!, () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (_) => UpdateAnalyseModel(_traitement, _ipServeur));
          Navigator.push(context, route).then((value) {
            initHomePage();
          }).catchError((error) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Erreur lors de la mise à jour des préférences concernant cette photo'),
              duration: Duration(seconds: 1),
            ));
          });
        }),
      ],
    );
  }

  Widget resultatNoPhoto() {
    return Column(
      children: [
        cardOption("Aucune photo sélectionné", ""),
        cardTitle("Suggestion: "),
        cardOption("- choisir une photo depuis l'historique", ""),
      ],
    );
  }

  Future<void> initHomePage() {
    return SharedPref.getIp().then((value) {
      _ipServeur = value;
      SharedPref.getUuid().then((cuid) {
        http
            .post(
          Uri.parse(_ipServeur + 'getCurrentTraitement/' + cuid),
        )
            .then((response) {
          if (response.statusCode == 201) {
            Map<String, dynamic> mapJson = json.decode(response.body);
            // print(mapJson);
            setState(() {
              _donneRecupere = true;
              if (mapJson["existe"] == "oui") {
                _possedePhoto = true;
                _traitement = Traitement.fromJson(mapJson);
              }
            });
          } else {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text('Mauvais code reponse du serveur'),
              duration: Duration(seconds: 2),
            ));
            print(response.statusCode);
          }
        }).catchError((onError, stackTrace) {
          Scaffold.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Erreur lors de la requête http. Le serveur est sans doute injoignable.'),
            duration: Duration(seconds: 2),
          ));
          print(onError);
        });
      }).onError((error, stackTrace) {
        Scaffold.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur appel sharedPref'),
          duration: Duration(seconds: 2),
        ));
        print(error);
      });
    });
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
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
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
