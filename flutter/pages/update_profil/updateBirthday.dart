// ignore_for_file: file_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/pages/authentification/page_connexion.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:flutter/material.dart';

class UpdateBirthday extends StatefulWidget {
  Utilisateur _user;
  UpdateBirthday(this._user, {Key? key}) : super(key: key);

  @override
  _UpdateBirthdayState createState() => _UpdateBirthdayState();
}

class _UpdateBirthdayState extends State<UpdateBirthday> {
  final _dateController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_pageUpdateBirthday');
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = widget._user.dateDeNaissance!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Date anniversaire"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            buildDate(),
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
            widget._user.dateDeNaissance = _dateController.text;
            final FirebaseAuthentification f = FirebaseAuthentification();
            f.updateDateFirebase(widget._user.cuid!, _dateController.text);
            Navigator.pop(context);
          }
        },
      );
}
