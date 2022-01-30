// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:flutter/material.dart';

class UpdateNom extends StatefulWidget {
  Utilisateur _user;
  UpdateNom(this._user, {Key? key}) : super(key: key);

  @override
  _UpdatePrenomState createState() => _UpdatePrenomState();
}

class _UpdatePrenomState extends State<UpdateNom> {
  final _nomController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdateNom');
  bool _envoieEnCours = false;

  @override
  void initState() {
    super.initState();

    _nomController.text = widget._user.nom!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nom"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            buildNom(),
            const SizedBox(height: 30),
            _envoieEnCours
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
          controller: _nomController,
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir votre nom' : null,
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
              _envoieEnCours = true;
            });
            widget._user.nom = _nomController.text;
            final FirebaseAuthentification f = FirebaseAuthentification();
            f.updateNomFirebase(widget._user.cuid!, _nomController.text);
            Navigator.pop(context);
          }
        },
      );
}
