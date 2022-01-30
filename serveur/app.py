from utils_bdd_connect import selectBDD
from flask import Flask, request, Response, send_file
from bdd_personne import savePersonneBDD, getAnalyseModelFavori, getListAnalyseForUser, updateAnalyseForUser, getListModelForUser, getNbPhotoUser, updateAutoUpdatePhotoForUser, getCurrentTraitement, getAllTraitement
from bdd_model import getListModelForTraitement, updateModelForUser
from bdd_analyse import getListAnalyseForTraitement
from entity_analyse import createCrop
from bdd_photo import savePhotoBDD, analysePhoto, definirPhoto, getAllPiece, updateValuePiece, updateTotalAndNoteTraitement
import hashlib
import os
from PIL import Image
import cv2

# sudo flask run -h 192.168.0.10 -p 80

app = Flask(__name__)


@app.route('/addPersonne/<cuid>', methods=['POST'])
def addPersonne(cuid):
    msg, HTTPstatus = savePersonneBDD(cuid)
    return Response('{"msg":"%s"}' % (msg), status=HTTPstatus, mimetype='application/json')


@app.route('/analyseModelFavori/<cuid>', methods=['POST'])
def analyseModelFavori(cuid):
    msg, HTTPstatus = getAnalyseModelFavori(cuid)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getListAnalyseForUser/<cuid>', methods=['POST'])
def listAnalyseForUser(cuid):
    msg, HTTPstatus = getListAnalyseForUser(cuid)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/updateAnalyseForUser/<cuid>/<id>', methods=['POST'])
def analyseForUser(cuid, id):
    msg, HTTPstatus = updateAnalyseForUser(cuid, id)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getListModelForUser/<cuid>', methods=['POST'])
def listModelForUser(cuid):
    msg, HTTPstatus = getListModelForUser(cuid)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getListModelForTraitement/<nameModel>', methods=['POST'])
def listModelForTraitement(nameModel):
    msg, HTTPstatus = getListModelForTraitement(nameModel)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getListAnalyseForTraitement/<nameAnalyse>', methods=['POST'])
def listAnalyseForTraitement(nameAnalyse):
    msg, HTTPstatus = getListAnalyseForTraitement(nameAnalyse)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/updateModelForUser/<cuid>/<id>', methods=['POST'])
def modelForUser(cuid, id):
    msg, HTTPstatus = updateModelForUser(cuid, id)
    print(msg)
    print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


def file_as_bytes(file):
    with file:
        return file.read()


@app.route('/uploadPhoto/<cuid>/<md5>', methods=['POST'])
def uploadPhoto(cuid, md5):
    # pour upload directement les photos sur le serveur
    # try:
    #     folder = '../photo/photo_brute'
    #     imageFile = request.files["image"]
    #     name_photo = str(len(listdir(folder)) + 1) + ".jpg"
    #     imageFile.save(folder + '/' + name_photo)
    #     return Response("ok", status=201, mimetype='application/json')
    # except Exception as e:
    #     print(e)
    #     return Response("error", status=500, mimetype='application/json')

    # fonctionnement normal de l'app
    try:
        imageFile = request.files["image"]

        nbPhotoUser = getNbPhotoUser(cuid)
        name_photo = cuid + '_' + str(nbPhotoUser)
        pathPhoto = './static/photoUser/' + name_photo + ".jpg"
        imageFile.save(pathPhoto)
        path_img = './static/photoUser/' + name_photo
        image = Image.open(pathPhoto)
        resized_image_small = image.resize(
            (int(image.size[0] / 20), int(image.size[1] / 20)))
        resized_image_small.save(path_img + "_small.jpg")
        resized_image_medium = image.resize(
            (int(image.size[0] / 8), int(image.size[1] / 8)))
        resized_image_medium.save(path_img + "_medium.jpg")

        md5Photo = hashlib.md5(file_as_bytes(
            open(pathPhoto, 'rb'))).hexdigest()
        if (md5 == md5Photo):
            savePhotoBDD(cuid, pathPhoto, name_photo)
            analysePhoto(cuid, pathPhoto)
            return Response("ok", status=201, mimetype='application/json')
        else:
            return Response("error md5", status=403, mimetype='application/json')
    except Exception as e:
        print(e)
        return Response("error", status=500, mimetype='application/json')


@app.route('/updateAutoUpdatePhotoForUser/<cuid>/<id>', methods=['POST'])
def updateAutoUpdatePhoto(cuid, id):
    msg, HTTPstatus = updateAutoUpdatePhotoForUser(cuid, id)
    print(msg)
    print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/updateTraitement/<idTraitement>/<idAnalyse>/<idModel>', methods=['POST'])
def updateTraitement(idTraitement, idAnalyse, idModel):
    try:
        result = selectBDD("""SELECT path_photo, cuid 
                         FROM traitement, photo, personne
                         WHERE photo.id_personne = personne.id_personne
                         AND traitement.id_photo = photo.id_photo
                         AND traitement.id_traitement = %d""" % int(idTraitement))
        pathPhoto = result[0][0]
        cuid = result[0][1]
        analysePhoto(cuid, pathPhoto, int(idAnalyse), int(idModel))
        return Response("ok", status=201, mimetype='application/json')
    except Exception as e:
        print(e)
        return Response("error", status=500, mimetype='application/json')


@app.route('/showImg')
def display_image():
    path = request.args.get('path')
    user_img = os.path.join('static', 'photoUser', path + ".jpg")
    return send_file(user_img, mimetype='image/jpeg')
    # return render_template('index.html', user_image=user_img)


@app.route('/getCurrentTraitement/<cuid>', methods=['POST'])
def currentTraitement(cuid):
    # print("hello")
    msg, HTTPstatus = getCurrentTraitement(cuid)
    # print(msg)
    # print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getAllTraitement/<cuid>', methods=['POST'])
def allTraitement(cuid):
    # print("hello")
    msg, HTTPstatus = getAllTraitement(cuid)
    # print(msg)
    # print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/definirPhoto/<idTraitement>', methods=['POST'])
def definirUnePhoto(idTraitement):
    msg, HTTPstatus = definirPhoto(idTraitement)
    # print(msg)
    # print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getAllPiece/<idTraitement>', methods=['POST'])
def allPiece(idTraitement):
    # print("hello")
    msg, HTTPstatus = getAllPiece(idTraitement)
    # print(msg)
    # print(HTTPstatus)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/getPhotoPiece/<idPiece>', methods=['POST', 'GET'])
def getPhotoPiece(idPiece):
    try:
        result = selectBDD("""SELECT name_photo, x, y, r
                        FROM piece, traitement t, photo
                        WHERE piece.id_traitement = t.id_traitement
                        AND photo.id_photo = t.id_photo
                        AND id_piece = %d""" % int(idPiece))
        namePhoto = result[0][0]
        x = int(result[0][1])
        y = int(result[0][2])
        r = int(result[0][3])
        pathPhoto = os.path.join('static', 'photoUser', namePhoto + ".jpg")
        img = cv2.imread(cv2.samples.findFile(pathPhoto))
        imgCrop = createCrop(img, x, y, r)
        pathCropPhoto = os.path.join(
            'static', 'photoUser', 'crop' + namePhoto + ".jpg")
        cv2.imwrite(pathCropPhoto, imgCrop)
        return send_file(pathCropPhoto, mimetype='image/jpeg')
    except Exception as e:
        print(e)
        return Response("error", status=500, mimetype='application/json')


@app.route('/updateValuePiece/<idPiece>/<estUnePiece>/<valuePiece>/<pieceBonneValeur>', methods=['POST'])
def valuePiece(idPiece, estUnePiece, valuePiece, pieceBonneValeur):
    msg, HTTPstatus = updateValuePiece(
        idPiece, estUnePiece, valuePiece, pieceBonneValeur)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


@app.route('/updateTotalAndNoteTraitement/<idTraitement>', methods=['POST'])
def totalNoteTraitement(idTraitement):
    msg, HTTPstatus = updateTotalAndNoteTraitement(idTraitement)
    return Response(msg, status=HTTPstatus, mimetype='application/json')


if __name__ == '__main__':
    app.run(debug=True)
