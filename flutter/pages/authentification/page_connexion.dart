import 'package:coco/utils/bddManager.dart';
import 'package:coco/utils/navigation_page.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class PageConnexion extends StatefulWidget {
  const PageConnexion({Key? key}) : super(key: key);

  @override
  _PageConnexionState createState() => _PageConnexionState();
}

class _PageConnexionState extends State<PageConnexion> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageConnexion');
  final _mailController = TextEditingController();
  final _mdpController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateController = TextEditingController();

  String? _idUtilisateur;
  String? _mdpUtilisatuer;
  String? _emailUtilisateur;
  String? _nomUtilisateur;
  String? _prenomUtilisateur;
  String? _dateUtilisateur;

  bool _estConnectable = true;
  String _message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buildMail(),
                      const SizedBox(
                        height: 30,
                      ),
                      buildMdp(),
                      if (!_estConnectable) const SizedBox(height: 30),
                      if (!_estConnectable) buildNom(),
                      if (!_estConnectable) const SizedBox(height: 30),
                      if (!_estConnectable) buildPrenom(),
                      if (!_estConnectable) const SizedBox(height: 30),
                      if (!_estConnectable) buildDate(),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              boutonPrincipal(),
              boutonSecondaire(),
              const SizedBox(
                height: 10,
              ),
              messageValidation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMail() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _mailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Adresse mail',
            icon: Icon(Icons.mail_outline),
          ),
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir une adresse mail' : null,
        ),
      );

  Widget buildMdp() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _mdpController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
            icon: Icon(Icons.lock),
          ),
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir un mot de passe' : null,
        ),
      );

  Widget buildNom() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _nomController,
          decoration: const InputDecoration(
            hintText: 'Nom de famille',
            icon: Icon(Icons.accessibility),
          ),
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir votre nom' : null,
        ),
      );

  Widget buildPrenom() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _prenomController,
          decoration: const InputDecoration(
            hintText: 'Prénom',
            icon: Icon(Icons.accessibility),
          ),
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir votre prénom' : null,
        ),
      );

  Widget buildDate() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _dateController,
          enableInteractiveSelection: false,
          focusNode:
              AlwaysDisabledFocusNode(), //to disable modication with Keyboard. Always same format
          decoration: const InputDecoration(
            hintText: 'Date de naissance',
            icon: Icon(Icons.calendar_today),
          ),
          onTap: () {
            _selectDate(context);
          },
          validator: (name) => name != null && name.isEmpty
              ? 'Renseigner votre date de naissance'
              : null,
        ),
      );

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        // _selectedDate = selected;
        _dateController.text =
            "${selected.day}/${selected.month}/${selected.year}";
      });
    }
  }

  Widget boutonPrincipal() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 22),
          primary: Theme.of(context).colorScheme.primary,
          onPrimary: Colors.white,
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary), //  Work!
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.0),
              side: const BorderSide(width: 3) // (Not working - Read note!!)
              ),
        ),
        child: _estConnectable
            ? const Text('Connexion')
            : const Text('Créer un compte'),
        onPressed: () async {
          final isValid = _formKey.currentState!.validate();

          if (isValid) {
            setState(() {
              _message = "";
            });
            soumettre();
          } else {
            setState(() {
              _message = "Veuillez remplir les champs ci dessus";
            });
          }
        },
      );

  Widget boutonSecondaire() => TextButton(
        style: TextButton.styleFrom(
          primary: Colors.grey,
        ),
        child: _estConnectable
            ? const Text(
                'Créer un compte',
                style: TextStyle(fontSize: 18),
              )
            : const Text('Connexion'),
        onPressed: () {
          setState(() {
            _estConnectable = !_estConnectable;
          });
        },
      );

  Widget messageValidation() => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          _message,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      );

  Future soumettre() async {
    final FirebaseAuthentification f = FirebaseAuthentification();

    _emailUtilisateur = _mailController.text;
    _mdpUtilisatuer = _mdpController.text;
    if (_estConnectable) {
      try {
        _idUtilisateur =
            await f.connexion(_emailUtilisateur!, _mdpUtilisatuer!);
        _message = "Connexion réussi";
        SharedPref.saveUuid(_idUtilisateur!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NavigationPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        _message = e.message!;
      }
    } else {
      _nomUtilisateur = _nomController.text;
      _prenomUtilisateur = _prenomController.text;
      _dateUtilisateur = _dateController.text;
      _message = await f.inscription(_emailUtilisateur!, _mdpUtilisatuer!,
          _nomUtilisateur!, _prenomUtilisateur!, _dateUtilisateur!);
      if (_message == "Inscription réussi") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NavigationPage(),
          ),
        );
      }
    }

    setState(() {
      _message = _message;
    });
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
