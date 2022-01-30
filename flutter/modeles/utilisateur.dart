// ignore_for_file: constant_identifier_names

class Utilisateur {
  String? cuid;
  bool? isAnonymous;
  String? email;
  String? nom;
  String? prenom;
  String? dateDeNaissance;
  int? idModelFavori;
  String? nameModelFavori;
  int? idAnalyseFavori;
  String? nameAnalyseFavori;
  bool? autoUpdatePhoto;

  Utilisateur();

  static const String CHAMP_CUID = 'cuid';
  static const String CHAMP_NOM = 'nom';
  static const String CHAMP_PRENOM = 'prenom';
  static const String CHAMP_DATE_DE_NAISSANCE = 'date_naissance';

  Utilisateur.fromMap(dynamic obj) {
    cuid = obj.id;
    nom = obj[CHAMP_NOM];
    prenom = obj[CHAMP_PRENOM];
    dateDeNaissance = obj[CHAMP_DATE_DE_NAISSANCE];
    isAnonymous = false;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[CHAMP_CUID] = cuid;
    map[CHAMP_NOM] = nom;
    map[CHAMP_PRENOM] = prenom;
    map[CHAMP_DATE_DE_NAISSANCE] = dateDeNaissance;
    return map;
  }
}
