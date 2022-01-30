from utils_bdd_connect import commitBDD, selectBDD
import cv2
from entity_analyse import executeAnalyse, createCrop
from entity_model import executeModel
import json


def savePhotoBDD(cuid, pathPhoto, namePhoto):
    commitBDD("""INSERT INTO photo (path_photo, name_photo, id_personne, date_photo) 
            SELECT '%s', '%s', id_personne, NOW()
            FROM personne
            WHERE cuid = '%s'""" % (pathPhoto, namePhoto, cuid))


def analysePhoto(cuid, pathPhoto, idAnalyse=None, idModel=None):
    reponse = selectBDD("""SELECT id_analyse, id_model, auto_update_photo
                            FROM personne
                            WHERE cuid = '%s'""" % cuid)
    if idAnalyse is None and idModel is None:
        idAnalyse = reponse[0][0]
        idModel = reponse[0][1]
    autoUpdatePhoto = reponse[0][2]

    result = selectBDD("""SELECT count(*) 
    FROM traitement t, photo p
    WHERE t.id_photo = p.id_photo
    AND t.id_analyse = %d
    AND t.id_model = %d
    AND p.path_photo = '%s'""" % (idAnalyse, idModel, pathPhoto))

    traitement_deja_effectue = result[0][0] >= 1
    if (not traitement_deja_effectue):
        commitBDD("""INSERT INTO traitement (id_photo, id_analyse, id_model, note)
        SELECT id_photo, %d, %d, 0.00
        FROM photo
        WHERE path_photo = '%s'""" % (int(idAnalyse), int(idModel), pathPhoto))

        circles = executeAnalyse(idAnalyse, pathPhoto)
        for circle in circles:
            img = cv2.imread(cv2.samples.findFile(pathPhoto))
            x = circles[circle]["x"]
            y = circles[circle]["y"]
            r = circles[circle]["r"]
            imgCrop = createCrop(
                img, x, y, r)
            value = executeModel(idModel, imgCrop, r, idAnalyse)
            # cv2.imshow("imgCrop", imgCrop)
            # cv2.waitKey(0)

            # print(x, y, r, value)
            commitBDD("""INSERT INTO piece (valeur_analyse, x, y, r, id_traitement)
            SELECT %d, %d, %d, %d, id_traitement
            FROM traitement t, photo p
            WHERE t.id_photo = p.id_photo
            AND p.path_photo = '%s'
            AND t.id_analyse = %d
            AND t.id_model = %d""" % (int(value), int(x), int(y), int(r), pathPhoto, int(idAnalyse), int(idModel)))
        resultat = selectBDD("""SELECT SUM(valeur_analyse) as somme
            FROM piece pi, traitement t, photo ph 
            WHERE pi.id_traitement = t.id_traitement
            AND t.id_photo = ph.id_photo
            AND ph.path_photo = '%s'
            AND t.id_analyse = %d
            AND t.id_model = %d""" % (pathPhoto, int(idAnalyse), int(idModel)))
        total = resultat[0][0]
        commitBDD("""UPDATE traitement
                    SET total = %d
                    WHERE id_photo = ( 	SELECT id_photo
                                        FROM photo
                                        WHERE path_photo = '%s')
                    AND id_analyse = %d
                    AND id_model = %d""" % (int(total), pathPhoto, idAnalyse, idModel))
        commitBDD("""UPDATE traitement
        SET traitement_fini = 1
        WHERE id_photo = (SELECT id_photo 
                        FROM photo
                        WHERE path_photo = '%s');""" % (pathPhoto))
    # mettre tous les traitements associé à la photo a choisi =null
    commitBDD("""UPDATE traitement
    SET est_choisi = 0
    WHERE id_photo = (SELECT id_photo 
                    FROM photo
                    WHERE path_photo = '%s');""" % (pathPhoto))
    # mettre ce traitement à choisi
    commitBDD("""UPDATE traitement
    SET est_choisi = 1
    WHERE id_analyse = %d
    AND id_model = %d
    AND id_photo = (SELECT id_photo 
                    FROM photo
                    WHERE path_photo = '%s');""" % (int(idAnalyse), int(idModel), pathPhoto))
    if (int(autoUpdatePhoto) == 1):
        # mettre toutes les photos associé au cuid a choisi = null
        commitBDD("""UPDATE photo
        SET est_choisi = 0
        WHERE id_personne = (SELECT id_personne 
                            FROM personne 
                            WHERE cuid = '%s')""" % cuid)
        # mettre cette photo a choisi
        commitBDD("""UPDATE photo
        SET est_choisi = 1
        WHERE path_photo = '%s'""" % pathPhoto)


def definirPhoto(idTraitement):
    newJson = json.loads('{}')
    try:
        result = selectBDD("""SELECT cuid, path_photo
                        FROM traitement, photo, personne
                        WHERE traitement.id_photo = photo.id_photo
                        AND photo.id_personne = personne.id_personne
                        AND traitement.id_traitement = %d""" % int(idTraitement))
        cuid = result[0][0]
        pathPhoto = result[0][1]
        # mettre toutes les photos associé au cuid a choisi = null
        commitBDD("""UPDATE photo
        SET est_choisi = 0
        WHERE id_personne = (SELECT id_personne 
                            FROM personne 
                            WHERE cuid = '%s')""" % cuid)
        # mettre cette photo a choisi
        commitBDD("""UPDATE photo
        SET est_choisi = 1
        WHERE path_photo = '%s'""" % pathPhoto)
        newJson["msg"] = "ok"
        return json.dumps(newJson, indent=2), 201
    except Exception as e:
        return e, 500


def getAllPiece(idTraitement):
    finalJson = json.loads('{}')
    try:
        pieces = selectBDD("""SELECT valeur_analyse, id_piece 
                        FROM piece
                        WHERE id_traitement = %s""" % int(idTraitement))
        cpt = 0
        for piece in pieces:
            newJson = json.loads('{}')
            newJson["valeur_analyse"] = piece[0]
            newJson["id_piece"] = piece[1]
            finalJson[str(cpt)] = newJson
            cpt += 1

        return json.dumps(finalJson, indent=2), 201
    except Exception as e:
        return e, 500


def updateValuePiece(idPiece, estUnePiece, valuePiece, pieceBonneValeur):
    try:
        if (pieceBonneValeur == '1'):
            commitBDD("""UPDATE piece
                        SET valeur_reelle = NULL, est_une_piece = 1
                        WHERE id_piece = %d""" % int(idPiece))
        else:
            if (estUnePiece == '1'):
                commitBDD("""UPDATE piece
                SET valeur_reelle = %d
                WHERE id_piece = %d""" % (int(valuePiece), int(idPiece)))
            else:
                commitBDD("""UPDATE piece
                SET est_une_piece = 0, valeur_reelle = NULL
                WHERE id_piece = %d""" % (int(idPiece)))
        return "ok", 201
    except Exception as e:
        # print(e)
        return e, 500


def updateTotalAndNoteTraitement(idTraitement):
    try:
        result = selectBDD("""SELECT COALESCE(sommeReelle, 0) + COALESCE(sommeAnalyse, 0) as sommeTotal, ROUND( ( COALESCE(nbCorrect, 0) / nbTotal ) * 5, 2) as noteTraitement
                            FROM 
                            (SELECT SUM(valeur_reelle) as sommeReelle, COUNT(*) as nbTotal
                            FROM piece
                            WHERE id_traitement = %d ) as reelle,
                            (SELECT SUM(valeur_analyse) as sommeAnalyse, COUNT(*) as nbCorrect
                            FROM piece
                            WHERE valeur_reelle IS NULL
                            AND est_une_piece = 1
                            AND id_traitement = %d ) as analyse""" % (int(idTraitement), int(idTraitement)))
        print(result)
        total = result[0][0]
        note = result[0][1]
        commitBDD("""UPDATE traitement
        SET total = %d, note = %s, est_analyse = 1
        WHERE id_traitement = %d""" % (int(total), note, int(idTraitement)))
        return "ok", 201
    except Exception as e:
        # print(e)
        return e, 500
