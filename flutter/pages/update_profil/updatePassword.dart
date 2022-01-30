// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UpdatePassword extends StatefulWidget {
  Utilisateur _user;
  UpdatePassword(this._user, {Key? key}) : super(key: key);

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool _widgetMailVisible = false;
  final _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdateMail');
  final _passwordController = TextEditingController();
  late UserCredential _userCredential;
  String _messageErreurNewMdp = '';
  String _messageErreurMdp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe"),
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
                      "Dans un premier temps, veuillez saisir votre mot de passe actuel pour le modifier",
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
                      "Veuillez entrer votre nouveau mot de passe",
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildNewPassword(),
                  const SizedBox(height: 30),
                  boutonValiderMail(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _messageErreurNewMdp,
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

  Widget buildNewPassword() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
          ),
          validator: (name) => name != null && name.isEmpty
              ? 'Saisir votre nouveau mot de passe'
              : null,
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
            _messageErreurNewMdp = '';
          });
          if (isValid) {
            _userCredential.user!
                .updatePassword(_newPasswordController.text)
                .then((value) {
              Navigator.pop(context);
            }).onError((error, stackTrace) {
              setState(() {
                _messageErreurNewMdp = error.toString();
              });
            });
          }
        },
      );
}
