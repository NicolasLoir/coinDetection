from utils_bdd_connect import commitBDD, selectBDD
import json


def saveModelBDD(idModel, nomModel, cheminModel, idDataset):
    try:
        model = selectBDD(
            "SELECT * FROM model WHERE id_model = %d" % idModel)
        if (len(model) > 0):
            commitBDD("UPDATE model SET name_model = '%s', path_model = '%s' WHERE id_model = %d" % (
                nomModel, cheminModel, idDataset))
        else:
            commitBDD("INSERT INTO model (id_model, name_model, path_model, id_dataset) VALUES (%d, '%s', '%s', %d);" % (
                idModel, nomModel, cheminModel, idDataset))
        sentence_print = "Sauvegarde du model %d nommé %s au chemin %s pour le dataset %d" % (
            idModel, nomModel, cheminModel, idDataset)
        print(sentence_print)
    except Exception as e:
        print(e)


def getChemin(idModel):
    try:
        model = selectBDD(
            "SELECT path_model FROM model WHERE id_model = %d" % idModel)
        path_model = model[0][0]
        return path_model
    except Exception as e:
        print(e)


def getListModelForTraitement(nameModel):
    newJson = json.loads('{}')
    try:
        models = selectBDD("""SELECT id_model, name_model
                                FROM model 
                                WHERE name_model = '%s'
                                UNION
                                SELECT id_model, name_model
                                FROM model
                                WHERE id_model NOT IN(SELECT id_model
                                                    FROM model 
                                                    WHERE id_model = '%s')""" % (nameModel, nameModel))
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


def updateModelForUser(cuid, id):
    newJson = json.loads('{}')
    try:
        commitBDD(
            "UPDATE personne SET id_model = %d WHERE cuid = '%s'" % (int(id), cuid))
        newJson["msg"] = "ok"
        return json.dumps(newJson, indent=2), 201
    except Exception as e:
        return e, 500
