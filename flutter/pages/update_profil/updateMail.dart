// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateMail extends StatefulWidget {
  Utilisateur _user;
  UpdateMail(this._user, {Key? key}) : super(key: key);

  @override
  _UpdateMailState createState() => _UpdateMailState();
}

class _UpdateMailState extends State<UpdateMail> {
  bool _widgetMailVisible = false;
  final _mailController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdateMail');
  final _passwordController = TextEditingController();
  late UserCredential _userCredential;
  String _messageErreurMail = '';
  String _messageErreurMdp = '';

  @override
  void initState() {
    super.initState();

    _mailController.text = widget._user.email!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adresse e-mail"),
      ),
      body: Column(
        children: [
          Visibility(
            visible: !_widgetMailVisible,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Dans un premier temps, veuillez saisir votre mot de passe pour changer votre adresse mail",
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildPassword(),
                  const SizedBox(height: 30),
                  boutonValiderPassword(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _messageErreurMdp,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _widgetMailVisible,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Veuillez entrer votre nouvelle adresse mail",
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildMail(),
                  const SizedBox(height: 30),
                  boutonValiderMail(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _messageErreurMail,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPassword() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
          ),
          validator: (name) => name != null && name.isEmpty
              ? 'Saisir votre mot de passe actuel'
              : null,
        ),
      );

  Widget boutonValiderPassword() => ElevatedButton(
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
        child: const Text('Valider'),
        onPressed: () {
          final isValid = _formKey.currentState!.validate();
          setState(() {
            _messageErreurMdp = '';
          });
          if (isValid) {
            FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: widget._user.email!,
                    password: _passwordController.text)
                .then((userCredential) {
              setState(() {
                _userCredential = userCredential;
                _messageErreurMdp = '';
                _widgetMailVisible = true;
              });
            }).onError((error, stackTrace) {
              setState(() {
                _messageErreurMdp = "Le mot de passe est invalide.";
              });
            });
          }
        },
      );

  Widget buildMail() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _mailController,
          validator: (name) =>
              name != null && name.isEmpty ? 'Saisir votre e-mail' : null,
        ),
      );

  Widget boutonValiderMail() => ElevatedButton(
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
          setState(() {
            _messageErreurMail = '';
          });
          if (isValid) {
            _userCredential.user!
                .updateEmail(_mailController.text)
                .then((value) {
              widget._user.email = _mailController.text;
              Navigator.pop(context);
            }).onError((error, stackTrace) {
              setState(() {
                _messageErreurMail = error.toString();
              });
            });
          }
        },
      );
}
