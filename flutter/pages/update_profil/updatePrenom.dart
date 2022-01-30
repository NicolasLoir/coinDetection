// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:flutter/material.dart';

class UpdatePrenom extends StatefulWidget {
  Utilisateur _user;
  UpdatePrenom(this._user, {Key? key}) : super(key: key);

  @override
  _UpdateNomState createState() => _UpdateNomState();
}

class _UpdateNomState extends State<UpdatePrenom> {
  final _prenomController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdatePreom');
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    _prenomController.text = widget._user.prenom!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prenom"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            buildNom(),
            const SizedBox(height: 30),
            _envoiEnCours
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  )
                : boutonValider()
          ],
        ),
      ),
    );
  }

  Widget buildNom() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _prenomController,
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir votre prénom' : null,
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
          final isValid = _formKey.currentState!.validate();
          if (isValid) {
            setState(() {
              _envoiEnCours = true;
            });
            widget._user.prenom = _prenomController.text;
            final FirebaseAuthentification f = FirebaseAuthentification();
            f.updatePrenomFirebase(widget._user.cuid!, _prenomController.text);
            Navigator.pop(context);
          }
        },
      );
}
