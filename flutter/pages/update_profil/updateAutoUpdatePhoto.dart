// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateAutoUpdatePhoto extends StatefulWidget {
  Utilisateur _user;
  String _ipAdress;
  UpdateAutoUpdatePhoto(this._user, this._ipAdress, {Key? key})
      : super(key: key);

  @override
  _UpdateAutoUpdatePhotoState createState() => _UpdateAutoUpdatePhotoState();
}

class _UpdateAutoUpdatePhotoState extends State<UpdateAutoUpdatePhoto> {
  late bool _autoUpdatePhoto;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdateAutoUpdatePhoto');
  String _messageErreur = '';
  bool _envoiEnCours = false;
  @override
  void initState() {
    super.initState();

    _autoUpdatePhoto = widget._user.autoUpdatePhoto!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maj automatique photo"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            messageInstruction(),
            const SizedBox(height: 30),
            buildSwitchButton(),
            const SizedBox(height: 30),
            _envoiEnCours
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  )
                : boutonValider(),
            const SizedBox(height: 30),
            messageErreur(),
          ],
        ),
      ),
    );
  }

  Widget buildSwitchButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            const Expanded(
              child:
                  Text('Mise à jour automatique', textAlign: TextAlign.center),
            ),
            const Expanded(
              child: Text('', textAlign: TextAlign.center),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain, // otherwise the logo will be tiny
                child: Switch(
                  value: _autoUpdatePhoto,
                  onChanged: (value) {
                    setState(() {
                      _autoUpdatePhoto = value;
                      // print(_autoUpdatePhoto);
                    });
                  },
                  activeTrackColor:
                      Theme.of(context).colorScheme.secondaryVariant,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );

  Widget messageInstruction() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Lorsque vous envoyé une photo au serveur, cette dernière peut automatiquement devenir la photo visible dans l'onglet 'Home'. Si vous préférez ne pas modifier la photo actuelle malgré l'envoi d'une nouvelle photo, veuillez désactiver l'option",
          style: TextStyle(color: Colors.black),
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
          int autoUpdatePhotoInt = _autoUpdatePhoto ? 1 : 0;
          http
              .post(
            Uri.parse(widget._ipAdress +
                'updateAutoUpdatePhotoForUser/' +
                widget._user.cuid! +
                '/' +
                autoUpdatePhotoInt.toString()),
          )
              .then((value) {
            _messageErreur = '';
            widget._user.autoUpdatePhoto = _autoUpdatePhoto;
            Navigator.of(context).pop();
          }).onError((error, stackTrace) {
            // print(error);
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
}
