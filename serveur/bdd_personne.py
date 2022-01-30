from utils_bdd_connect import commitBDD, selectBDD
import json


def savePersonneBDD(cuid):
    try:
        personne = selectBDD(
            "SELECT * FROM personne WHERE cuid = '%s'" % cuid)
        if (len(personne) > 0):
            return "La personne avec le cuid %s existe deja: insertion impossible" % (cuid), 500
        else:
            commitBDD("INSERT INTO personne (cuid, id_analyse, id_model) VALUES ('%s', 1, 1);" % (
                cuid))
            return "La personne avec le cuid %s est sauvegarde en bdd" % (cuid), 201
    except Exception as e:
        return e, 500  # Internal server error


def getAnalyseModelFavori(cuid):
    newJson = json.loads('{}')
    try:
        personne = selectBDD(
            "SELECT * FROM personne WHERE cuid = '%s'" % cuid)
        if (len(personne) > 0):
            personne = selectBDD(
                "SELECT a.id_analyse, name_analyse, m.id_model, name_model, auto_update_photo FROM personne p, analyse a, model m WHERE p.id_analyse = a.id_analyse AND p.id_model = m.id_model AND cuid = '%s'" % cuid)
            idAnalyse = personne[0][0]
            nameAnalyse = personne[0][1]
            idModel = personne[0][2]
            nameModel = personne[0][3]
            autoUpdatePhoto = personne[0][4]
            newJson["idAnalyse"] = idAnalyse
            newJson["nameAnalyse"] = nameAnalyse
            newJson["idModel"] = idModel
            newJson["nameModel"] = nameModel
            newJson["autoUpdatePhoto"] = autoUpdatePhoto
            json_str = json.dumps(newJson, indent=2)
            return json_str, 201
        else:
            newJson["msg"] = "La personne avec le cuid %s n'existe pas" % (
                cuid)
            return json.dumps(newJson, indent=2), 500
    except Exception as e:
        print(e)
        newJson["msg"] = "Une erreur est survenu côté serveur. Veuillez réessayer plus tard"
        return json.dumps(newJson, indent=2), 500  # Internal server error


def getListAnalyseForUser(cuid):
    newJson = json.loads('{}')
    try:
        personne = selectBDD(
            "SELECT * FROM personne WHERE cuid = '%s'" % cuid)
        if (len(personne) > 0):
            analyses = selectBDD("""SELECT a.id_analyse, name_analyse
                                 FROM analyse a, personne p
                                 WHERE a.id_analyse = p.id_analyse
                                 AND p.cuid='%s'
                                 UNION
                                 SELECT id_analyse, name_analyse
                                 FROM analyse
                                 WHERE id_analyse NOT IN(SELECT a.id_analyse
                                                         FROM analyse a, personne p
                                                         WHERE a.id_analyse=p.id_analyse
                                                         AND p.cuid='%s')""" % (cuid, cuid))
            for analyse in analyses:
                id_analyse = analyse[0]
                name_analyse = analyse[1]
                newJson[name_analyse] = int(id_analyse)
            json_str = json.dumps(newJson, indent=2)
            return json_str, 201
        else:
            newJson["msg"] = "La personne avec le cuid %s n'existe pas" % (
                cuid)
            return json.dumps(newJson, indent=2), 500
    except Exception as e:
        print(e)
        newJson["msg"] = "Une erreur est survenu côté serveur. Veuillez réessayer plus tard"
        return json.dumps(newJson, indent=2), 500  # Internal server error


def updateAnalyseForUser(cuid, id):
    newJson = json.loads('{}')
    try:
        commitBDD(
            "UPDATE personne SET id_analyse = %d WHERE cuid = '%s'" % (int(id), cuid))
        newJson["msg"] = "ok"
        return json.dumps(newJson, indent=2), 201
    except Exception as e:
        return e, 500


def getListModelForUser(cuid):
    newJson = json.loads('{}')
    try:
        personne = selectBDD(
            "SELECT * FROM personne WHERE cuid = '%s'" % cuid)
        if (len(personne) > 0):
            models = selectBDD("""SELECT m.id_model, name_model
                                 FROM model m, personne p
                                 WHERE m.id_model = p.id_model
                                 AND p.cuid = '%s'
                                 UNION
                                 SELECT id_model, name_model
                                 FROM model
                                 WHERE id_model NOT IN(SELECT m.id_model
                                                         FROM model m, personne p
                                                         WHERE m.id_model = p.id_model
                                                         AND p.cuid='%s')""" % (cuid, cuid))

            for model in models:
                id_model = model[0]
                name_model = model[1]
                newJson[name_model] = int(id_model)
            json_str = json.dumps(newJson, indent=2)
            return json_str, 201
        else:
            newJson["msg"] = "La personne avec le cuid %s n'existe pas" % (
                cuid)
            return json.dumps(newJson, indent=2), 500
    except Exception as e:
        print(e)
        newJson["msg"] = "Une erreur est survenu côté serveur. Veuillez réessayer plus tard"
        return json.dumps(newJson, indent=2), 500  # Internal server error


def getNbPhotoUser(cuid):
    response = selectBDD("""SELECT COUNT(*)
                            FROM photo, personne
                            WHERE photo.id_personne = personne.id_personne
                            AND personne.cuid = '%s'""" % cuid)
    return response[0][0]


def updateAutoUpdatePhotoForUser(cuid, autoUpdatePhoto):
    newJson = json.loads('{}')
    try:
        commitBDD(
            "UPDATE personne SET auto_update_photo = %d WHERE cuid = '%s'" % (int(autoUpdatePhoto), cuid))
        newJson["msg"] = "ok"
        return json.dumps(newJson, indent=2), 201
    except Exception as e:
        return e, 500


def getCurrentTraitement(cuid):
    newJson = json.loads('{}')
    # finalJson = json.loads('{}')
    try:
        response = selectBDD("""SELECT est_analyse, note, total, name_photo, date_photo, id_traitement, name_analyse, name_model, p.est_choisi
                FROM traitement t, photo p, personne, analyse a, model m
                WHERE t.id_photo = p.id_photo
                AND p.id_personne = personne.id_personne
                AND t.id_analyse = a.id_analyse
                AND t.id_model = m.id_model
                AND t.traitement_fini = 1
                AND t.est_choisi = 1
                AND p.est_choisi = 1
                AND cuid = '%s'""" % cuid)
        if (len(response) == 1):
            newJson["existe"] = "oui"
            newJson["est_analyse"] = response[0][0]
            newJson["note"] = str(response[0][1])
            newJson["total"] = response[0][2]
            newJson["name_photo"] = response[0][3]
            newJson["date_photo"] = str(response[0][4])
            newJson["id_traitement"] = response[0][5]
            newJson["name_analyse"] = response[0][6]
            newJson["name_model"] = response[0][7]
            newJson["est_choisi"] = response[0][8]
        else:
            newJson["existe"] = "non"
        # print(json.dumps(newJson, indent=2))
        # finalJson["1"] = newJson
        return json.dumps(newJson, indent=2), 201
    except Exception as e:
        # print(e)
        return e, 500


def getAllTraitement(cuid):
    finalJson = json.loads('{}')
    try:
        traitements = selectBDD("""SELECT est_analyse, note, total, name_photo, date_photo, id_traitement, name_analyse, name_model, p.est_choisi
                FROM traitement t, photo p, personne, analyse a, model m
                WHERE t.id_photo = p.id_photo
                AND p.id_personne = personne.id_personne
                AND t.id_analyse = a.id_analyse
                AND t.id_model = m.id_model
                AND t.traitement_fini = 1
                AND t.est_choisi = 1
                AND cuid = '%s'""" % cuid)
        cpt = 0
        for traitement in traitements:
            newJson = json.loads('{}')
            newJson["est_analyse"] = traitement[0]
            newJson["note"] = str(traitement[1])
            newJson["total"] = traitement[2]
            newJson["name_photo"] = traitement[3]
            newJson["date_photo"] = str(traitement[4])
            newJson["id_traitement"] = traitement[5]
            newJson["name_analyse"] = traitement[6]
            newJson["name_model"] = traitement[7]
            newJson["est_choisi"] = traitement[8]
            finalJson[str(cpt)] = newJson
            cpt += 1

        # print(json.dumps(newJson, indent=2))
        # finalJson["1"] = newJson
        return json.dumps(finalJson, indent=2), 201
    except Exception as e:
        # print(e)
        return e, 500
