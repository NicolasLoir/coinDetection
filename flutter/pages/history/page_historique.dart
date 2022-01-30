import 'package:coco/modeles/traitement.dart';
import 'package:coco/pages/history/selectTraitement.dart';
import 'package:flutter/material.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  _HistoriqueState createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  late String _ipServeur;
  bool _donneRecupere = false;
  List<Traitement> _traitements = [];
  String _sortSelected = 'de la date';
  final Map<String, int> _modelMap = {
    'du total en €': 0,
    'de la note sur 5': 1,
    'de la date': 2,
  };

  @override
  void initState() {
    super.initState();
    initPageHistorique();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        child: SafeArea(
          child: monHistorique(),
        ),
        onRefresh: () {
          return initPageHistorique();
        },
      ),
    );
  }

  Widget monHistorique() {
    if (_donneRecupere) {
      if (_traitements.isNotEmpty) {
        return ListView(
          children: [
            const SizedBox(height: 10),
            messageInstruction(),
            buildDropDownList(),
            createListPhoto(),
          ],
        );
      } else {
        return createViewNoPhoto();
      }
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

  Widget messageInstruction() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Vous pouvez choisir de trier les résultat en fonction ...",
          style: TextStyle(color: Colors.black),
        ),
      );

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
            if (newValue == 'du total en €') {
              _traitements.sort((a, b) => b.total!.compareTo(a.total!));
            } else if (newValue == 'de la note sur 5') {
              _traitements.sort((a, b) => b.note!.compareTo(a.note!));
            } else {
              _traitements.sort((a, b) => b.datePhoto!.compareTo(a.datePhoto!));
            }
            setState(() {
              _sortSelected = newValue!;
              _traitements = _traitements;
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

  Widget createViewNoPhoto() {
    return Column(
      children: [
        cardOptionInfo("Aucune photo disponible", ""),
        cardTitle("Suggestion: "),
        cardOptionInfo("- Envoyer une photo au serveur", ""),
      ],
    );
  }

  Widget cardOptionInfo(String title, String sousTitre) {
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

  Future<void> initPageHistorique() {
    return SharedPref.getIp().then((value) {
      _ipServeur = value;
      SharedPref.getUuid().then((cuid) {
        http
            .post(
          Uri.parse(_ipServeur + 'getAllTraitement/' + cuid),
        )
            .then((response) {
          if (response.statusCode == 201) {
            // print(response.body);

            Map<String, dynamic> mapJson = json.decode(response.body);
            List<Traitement> traitements = [];
            for (final name in mapJson.keys) {
              final value = mapJson[name];
              // print('$name,$value');
              final valueJson = json.encode(value);
              // print(valueJson);
              Map<String, dynamic> mapTraitement = json.decode(valueJson);
              traitements.add(Traitement.fromJson(mapTraitement));
            }
            traitements.sort((a, b) => b.datePhoto!.compareTo(a.datePhoto!));
            setState(() {
              _traitements = traitements;
              _donneRecupere = true;
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

  Widget createListPhoto() {
    return ListView.builder(
      itemCount: _traitements.length,
      itemBuilder: (BuildContext context, int position) {
        return cardOption(_traitements[position], () {
          MaterialPageRoute route = MaterialPageRoute(
              builder: (_) =>
                  SelectTraitement(_traitements[position], _ipServeur));
          Navigator.push(context, route).then((value) {
            initPageHistorique();
          }).catchError((error) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Erreur lors de la mise à jour des préférences concernant cette photo'),
              duration: Duration(seconds: 1),
            ));
          });
        });
      },
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget cardOption(Traitement t, Function functionOnTap) {
    NetworkImage image = NetworkImage(_ipServeur + t.urlPhoto! + "_small");
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.all(0),
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: image,
        ),
        title: Text(
          (t.total! / 100).toString() + "€",
          style: TextStyle(
              color: t.estChoisi!
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black),
        ),
        subtitle: t.estAnalyse!
            ? Text(
                t.note!.toString() + "/5",
                style: TextStyle(
                    color: t.estChoisi!
                        ? Theme.of(context).colorScheme.primaryVariant
                        : Colors.grey.shade700),
              )
            : Text(
                "Pas de note",
                style: TextStyle(
                    color: t.estChoisi!
                        ? Theme.of(context).colorScheme.primaryVariant
                        : Colors.grey.shade700),
              ),
        trailing: Text(
          t.datePhoto!,
          style: TextStyle(
              color: t.estChoisi!
                  ? Theme.of(context).colorScheme.primaryVariant
                  : Colors.grey.shade700),
        ),
        onTap: () {
          functionOnTap();
        },
      ),
    );
  }
}
