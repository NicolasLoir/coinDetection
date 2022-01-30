import 'package:coco/utils/sharedPref.dart';

class Traitement {
  String? name;
  double? note;
  int? total;
  bool? estAnalyse;
  String? urlPhoto;
  String? datePhoto;
  int? idTraitement;
  String? nameModel;
  String? nameAnalyse;
  bool? estChoisi;

  Traitement.fromJson(Map<String, dynamic> chaineJson) {
    // print(chaineJson);
    // print("ok inside");
    name = chaineJson['name_photo'];
    urlPhoto = 'showImg?path=' + name!;
    // print("ok 3");
    estAnalyse = (int.parse(chaineJson['est_analyse'].toString()) == 1);
    estChoisi = (int.parse(chaineJson['est_choisi'].toString()) == 1);
    // print("ok 4");
    // print(chaineJson['note'].toString());
    note = double.parse(chaineJson['note'].toString());
    // print("ok 5");

    total = int.parse(chaineJson['total'].toString());
    datePhoto = chaineJson['date_photo'];
    idTraitement = chaineJson['id_traitement'];
    nameModel = chaineJson['name_model'];
    // print("ok 5");
    // print(chaineJson['name_model'].toString());
    nameAnalyse = chaineJson['name_analyse'];
    // print("Ok 6");
  }
}
