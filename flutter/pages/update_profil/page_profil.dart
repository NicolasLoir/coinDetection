import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/pages/authentification/page_connexion.dart';
import 'package:coco/pages/update_profil/updateAnalyse.dart';
import 'package:coco/pages/update_profil/updateAutoUpdatePhoto.dart';
import 'package:coco/pages/update_profil/updateBirthday.dart';
import 'package:coco/pages/update_profil/updateMail.dart';
import 'package:coco/pages/update_profil/updateModel.dart';
import 'package:coco/pages/update_profil/updateNom.dart';
import 'package:coco/pages/update_profil/updatePassword.dart';
import 'package:coco/pages/update_profil/updatePrenom.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final FirebaseAuthentification authentification = FirebaseAuthentification();
  Utilisateur _user = Utilisateur()..isAnonymous = true;
  bool _ipRecupere = false;
  late String _ipAdress;

  @override
  void initState() {
    super.initState();

    initProfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: RefreshIndicator(
        child: SafeArea(
          child: monProfil(),
        ),
        onRefresh: () {
          return initProfil();
        },
      ),
    );
  }

  Future<void> initProfil() {
    return SharedPref.getIp().then((value) {
      setState(() {
        _ipAdress = value;
        _ipRecupere = true;
      });
      SharedPref.getUuid()
          .then((cuid) => createInstanceUser(cuid).then((utilisateur) {
                setState(() {
                  _user = utilisateur;
                });
              }).catchError((error) {
                Scaffold.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Erreur lors du chargement des données du profil'),
                  duration: Duration(seconds: 1),
                ));
                // print(error);
              }));
    });
  }

  Widget configAdressServeur() {
    return Column(
      children: [
        cardTitle("Information réseau"),
        if (_ipRecupere) cardOption("Adresse IP serveur", _ipAdress, () {}),
      ],
    );
  }

  Widget monProfil() {
    if (_user.isAnonymous!) {
      return ListView(
        children: [
          configAdressServeur(),
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
    } else {
      return ListView(
        children: [
          configAdressServeur(),
          cardTitle("Mon compte"),
          cardOption("Nom", _user.nom!, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (_) => UpdateNom(_user));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text('Erreur lors de la mise à jour du nom'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("Prenom", _user.prenom!, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (_) => UpdatePrenom(_user));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text('Erreur lors de la mise à jour du prénom'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("Date anniversaire", _user.dateDeNaissance!, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (_) => UpdateBirthday(_user));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Erreur lors de la mise à jour de la date de naissance'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("Adresse e-mail", _user.email!, () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (_) => UpdateMail(_user));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content:
                    Text('Erreur lors de la mise à jour de l\'adresse mail'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("Mot de passe", "", () {
            MaterialPageRoute route =
                MaterialPageRoute(builder: (_) => UpdatePassword(_user));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text('Erreur lors de la mise à jour du mot de passe'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardTitle("Préférence pour..."),
          cardOption("localiser une pièce", _user.nameAnalyseFavori!, () {
            MaterialPageRoute route = MaterialPageRoute(
                builder: (_) => UpdateAnalyse(_user, _ipAdress));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Erreur lors de la mise à jour de la préférence pour localiser une pièce'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("reconnaitre une pièce", _user.nameModelFavori!, () {
            MaterialPageRoute route = MaterialPageRoute(
                builder: (_) => UpdateModel(_user, _ipAdress));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Erreur lors de la mise à jour de la préférence pour reconnaitre une pièce'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardOption("Mettre à jour automatiquement la photo",
              _user.autoUpdatePhoto! ? "oui" : "non", () {
            MaterialPageRoute route = MaterialPageRoute(
                builder: (_) => UpdateAutoUpdatePhoto(_user, _ipAdress));
            Navigator.push(context, route).then((value) {
              setState(() {
                _user = _user;
              });
            }).catchError((error) {
              Scaffold.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Erreur lors de la mise à jour de la préférence pour mettre à jour automatiquement la photo'),
                duration: Duration(seconds: 1),
              ));
              // print(error);
            });
          }),
          cardTitle("Action de compte"),
          cardOption("Déconnexion", "", () {
            authentification.deconnecter().then((resultat) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PageConnexion()));
            });
          }),
        ],
        physics: const AlwaysScrollableScrollPhysics(),
      );
    }
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

  Widget cardOption(String title, String sousTitre, Function functionOnTap) {
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
        onTap: () {
          functionOnTap();
        },
      ),
    );
  }
}

Future<Utilisateur> createInstanceUser(String cuid) async {
  final _auth = FirebaseAuth.instance;
  final currentUser = _auth.currentUser!;
  String? userEmail = currentUser.email;
  QuerySnapshot querySnap = await FirebaseFirestore.instance
      .collection('user')
      .where('cuid', isEqualTo: cuid)
      .get();
  List<Utilisateur> users =
      querySnap.docs.map((donnees) => Utilisateur.fromMap(donnees)).toList();
  Utilisateur user = Utilisateur();
  user
    ..cuid = cuid
    ..email = userEmail
    ..nom = users[0].nom
    ..prenom = users[0].prenom
    ..dateDeNaissance = users[0].dateDeNaissance
    ..isAnonymous = false;

  final ipAdress = await SharedPref.getIp();

  final response = await http.post(
    Uri.parse(ipAdress + 'analyseModelFavori/' + cuid),
  );
  final info = jsonDecode(response.body);
  user
    ..idAnalyseFavori = info["idAnalyse"]
    ..idModelFavori = info["idModel"]
    ..nameAnalyseFavori = info["nameAnalyse"]
    ..nameModelFavori = info["nameModel"]
    ..autoUpdatePhoto = info["autoUpdatePhoto"] == 1;
  return user;
}
