// ignore_for_file: non_constant_identifier_names

import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/pages/authentification/page_connexion.dart';
import 'package:coco/utils/navigation_page.dart';
import 'package:coco/utils/bddManager.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageDemarrage extends StatefulWidget {
  const PageDemarrage({Key? key}) : super(key: key);

  @override
  _PageDemarrageState createState() => _PageDemarrageState();
}

class _PageDemarrageState extends State<PageDemarrage> {
  @override
  void initState() {
    _initialiser();
    super.initState();
  }

  Future _initialiser() async {
    SharedPref.saveIp("http://192.168.0.10:80/");

    final _auth = await FirebaseAuth.instance;
    final currentUser = _auth.currentUser;
    // if (currentUser != null) {
    //   final FirebaseAuthentification authentification =
    //       FirebaseAuthentification();
    //   authentification.deconnecter();
    //   // currentUser = null;
    // }
    setState(() {
      if (currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const PageConnexion(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NavigationPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargement'),
      ),
      body: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.black,
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
