from utils_bdd_connect import commitBDD, selectBDD
from entity_analyse import analyseHoughCircles, dummyAnalyse
import json


def saveAnalyseBDD(idAnalyse, nameAnalyse):
    try:
        analyse = selectBDD(
            "SELECT * FROM analyse WHERE id_analyse = %d" % idAnalyse)
        if (len(analyse) > 0):
            commitBDD("UPDATE analyse SET name_analyse = '%s' WHERE id_analyse = %d" % (
                nameAnalyse, idAnalyse))
        else:
            commitBDD("INSERT INTO analyse (id_analyse, name_analyse) VALUES (%d, '%s');" % (
                idAnalyse, nameAnalyse))
        print("L'analyse %s nommé %s est sauvegarde en bdd" %
              (idAnalyse, nameAnalyse))
    except Exception as e:
        print(e)


def getListAnalyseForTraitement(nameAnalyse):
    newJson = json.loads('{}')
    try:
        models = selectBDD("""SELECT id_analyse, name_analyse
                                FROM analyse 
                                WHERE name_analyse = '%s'
                                UNION
                                SELECT id_analyse, name_analyse
                                FROM analyse
                                WHERE id_analyse NOT IN(SELECT id_analyse
                                                    FROM analyse 
                                                    WHERE id_analyse = '%s')""" % (nameAnalyse, nameAnalyse))
        for model in models:
            id_model = model[0]
            name_model = model[1]
            newJson[name_model] = int(id_model)
        json_str = json.dumps(newJson, indent=2)
        return json_str, 201
    except Exception as e:
        print(e)
        newJson["msg"] = "Une erreur est survenu côté serveur. Veuillez réessayer plus tard"
        return json.dumps(newJson, indent=2), 500
