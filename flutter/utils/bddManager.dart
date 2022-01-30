// import 'dart:async';

// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coco/modeles/utilisateur.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

class FirebaseAuthentification {
  final FirebaseAuth _authentificationFirebase = FirebaseAuth.instance;
  static final FirebaseFirestore bdd = FirebaseFirestore.instance;

  Future<String> connexion(String email, String mdp) async {
    await _authentificationFirebase.signInWithEmailAndPassword(
        email: email, password: mdp);
    return _authentificationFirebase.currentUser!.uid;
  }

  Future<String> inscription(
      String email, String mdp, String nom, String prenom, String date) async {
    try {
      await _authentificationFirebase.createUserWithEmailAndPassword(
          email: email, password: mdp);
      //createUserWithEmailAndPassword modifie _authentificationFirebase.currentUser
      String cuid = _authentificationFirebase.currentUser!.uid;
      Utilisateur user = Utilisateur();
      user
        ..cuid = cuid
        ..nom = nom
        ..prenom = prenom
        ..dateDeNaissance = date;
      bdd.collection('user').add(user.toMap());

      final ipAdress = await SharedPref.getIp();
      print(ipAdress);

      final response = await http
          .post(
        Uri.parse(ipAdress + 'addPersonne/' + cuid),
      )
          .catchError((error) {
        print(error);
        return http.Response("body", 500);
      });

      if (response.statusCode == 201) {
        // print(response.body);
        SharedPref.saveUuid(cuid);
      } else {
        return handleInscriptionErrorServeur(cuid);
      }
    } on FirebaseAuthException catch (e) {
      return e.message!;
    }
    return 'Inscription réussi';
  }

  Future<String> handleInscriptionErrorServeur(String cuid) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('user')
        .where('cuid', isEqualTo: cuid)
        .get();
    QueryDocumentSnapshot doc = querySnap.docs[0];
    DocumentReference docRef = doc.reference;
    String idDoc = docRef.id;
    bdd.collection('user').doc(idDoc).delete();
    await FirebaseAuth.instance.currentUser!.delete();
    return "Erreur lors de la création depuis le serveur. Veuillez réessayer plus tard";
  }

  Future deconnecter() async {
    await _authentificationFirebase.signOut();
    SharedPref.removeUuid();
  }

  void updateNomFirebase(String cuid, String nom) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('user')
        .where('cuid', isEqualTo: cuid)
        .get();
    String idDoc = querySnap.docs[0].reference.id;
    FirebaseFirestore.instance
        .collection('user')
        .doc(idDoc)
        .update({'nom': nom});
  }

  void updatePrenomFirebase(String cuid, String prenom) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('user')
        .where('cuid', isEqualTo: cuid)
        .get();
    String idDoc = querySnap.docs[0].reference.id;
    FirebaseFirestore.instance
        .collection('user')
        .doc(idDoc)
        .update({'prenom': prenom});
  }

  void updateDateFirebase(String cuid, String date) async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection('user')
        .where('cuid', isEqualTo: cuid)
        .get();
    String idDoc = querySnap.docs[0].reference.id;
    FirebaseFirestore.instance
        .collection('user')
        .doc(idDoc)
        .update({'date_naissance': date});
  }
}
