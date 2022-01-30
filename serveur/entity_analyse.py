import numpy as np
import imutils
import cv2
import json


def executeAnalyse(idAnalyse, cheminPhoto):
    if (idAnalyse == 1):
        return analyseHoughCircleWide(cheminPhoto)
    elif (idAnalyse == 2):
        return analyseHoughCircleNormal(cheminPhoto)
    elif (idAnalyse == 3):
        return analyseHoughCircleCLose(cheminPhoto)
    elif (idAnalyse == 4):
        return analyseHoughCircleSuperWide(cheminPhoto)
    # Pas de superclose car peu provoquer un temps de chargement tres tres important car detecte de nombreux cercles
    # elif(idAnalyse == 5):
    #     return analyseHoughCircleSuperCLose(cheminPhoto)
    else:
        print("Pas d'idAnalyse associé à l'id %d" % idAnalyse)


def analyseHoughCircleInside(idAnalyse, cheminPhoto):
    if (idAnalyse == 1):
        return analyseHoughCircleInsideWide(cheminPhoto)
    elif (idAnalyse == 2):
        return analyseHoughCircleInsideNormal(cheminPhoto)
    elif (idAnalyse == 3):
        return analyseHoughCircleInsideClose(cheminPhoto)
    elif (idAnalyse == 4):
        return analyseHoughCircleInsideSuperWide(cheminPhoto)
    elif(idAnalyse == 5):
        return analyseHoughCircleInsideSuperClose(cheminPhoto)


def createJsonCircle(x, y, r):
    json_temp = json.loads('{}')
    json_temp["x"] = int(x)
    json_temp["y"] = int(y)
    json_temp["r"] = int(r)
    return json_temp


def analyseHoughCircles(cheminPhoto, reduction, blur=(7, 7)):
    json_dic = json.loads('{}')
    img = cv2.imread(cv2.samples.findFile(cheminPhoto))
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img_blur = cv2.GaussianBlur(gray, blur, 0)

    reference = img.shape[0]/reduction
    radiusMinimum = int(reference)  # int(img.shape[0]/14)
    radiusMaximum = int(reference * 2)
    circles = cv2.HoughCircles(img_blur, cv2.HOUGH_GRADIENT, 1,
                               1.9 * reference, param1=75, param2=42, minRadius=radiusMinimum, maxRadius=radiusMaximum)
    nb_circle = 0
    if circles is not None:
        circles = np.uint16(np.around(circles))
        for i in circles[0, :]:
            x = i[0]
            y = i[1]
            r = i[2]
            json_dic["circle_"+str(nb_circle)] = createJsonCircle(x, y, r)
            nb_circle += 1
    # print("nombre de cercle détecté, 57, entity_analyse", nb_circle)
    print("analyseHoughCircle", json_dic)
    print(len(json_dic))
    return json_dic
    # json_str = json.dumps(json_dic, indent=2)
    # print(json_str)


def pieceAlreadyDected(jsonCurrentPiece, jsonToWatch):
    actualX = int(jsonCurrentPiece["x"])
    actualY = int(jsonCurrentPiece["y"])
    for piece in jsonToWatch:
        x = int(jsonToWatch[piece]["x"])
        y = int(jsonToWatch[piece]["y"])
        r = int(jsonToWatch[piece]["r"])
        detection = (actualX >= (x - r) and actualX <= (x + r)
                     ) and (actualY >= (y - r) and actualY <= (y + r))
        if (detection):
            return detection
    return False


def analyseHoughCirclesV2(cheminPhoto):
    jsonDicAnalyse = analyseHoughCircles(cheminPhoto, 24)
    jsonFinal = json.loads('{}')
    cpt = 0
    for piece in jsonDicAnalyse:
        jsonCurrentPiece = jsonDicAnalyse[piece]
        if (not pieceAlreadyDected(jsonCurrentPiece, jsonFinal)):
            jsonFinal["piece_" + str(cpt)] = jsonCurrentPiece
        cpt += 1
    return jsonFinal


def pieceAlreadyDectedV2(jsonCurrentPiece, jsonToWatch):
    actualX = int(jsonCurrentPiece["x"])
    actualY = int(jsonCurrentPiece["y"])
    actualR = int(jsonCurrentPiece["r"])
    for piece in jsonToWatch:
        x = int(jsonToWatch[piece]["x"])
        y = int(jsonToWatch[piece]["y"])
        r = int(jsonToWatch[piece]["r"])
        detection = (actualX >= (x - r) and actualX <= (x + r)) and ((actualY - actualR <= y + r) and (actualY + actualR >= y - r)
                                                                     ) or (actualY >= (y - r) and actualY <= (y + r)) and ((actualX - actualR <= x + r) and (actualX + actualR >= x - r))

        if (detection):
            return detection
    return False


def analyseHoughCirclesV3(cheminPhoto, reduction, blur=(17, 17)):
    jsonDicAnalyse = analyseHoughCircles(cheminPhoto, reduction, blur)
    jsonFinal = json.loads('{}')
    cpt = 0
    for piece in jsonDicAnalyse:
        jsonCurrentPiece = jsonDicAnalyse[piece]
        if (not pieceAlreadyDectedV2(jsonCurrentPiece, jsonFinal)):
            jsonFinal["piece_" + str(cpt)] = jsonCurrentPiece
            print("analyseHoughCirclesV3", cpt)
        cpt += 1

    return jsonFinal


def analyseHoughCircleSuperWide(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 36)


def analyseHoughCircleWide(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 24)


def analyseHoughCircleNormal(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 18)


def analyseHoughCircleCLose(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 12)


def analyseHoughCircleSuperCLose(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 6)


def analyseHoughCircleInsideSuperWide(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 24)


def analyseHoughCircleInsideWide(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 16, (1, 1))


def analyseHoughCircleInsideNormal(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 12, (1, 1))


def analyseHoughCircleInsideClose(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 8, (1, 1))


def analyseHoughCircleInsideSuperClose(cheminPhoto):
    return analyseHoughCirclesV3(cheminPhoto, 4, (1, 1))


def dummyAnalyse(cheminPhoto):
    json_dic = json.loads('{}')
    img = cv2.imread(cv2.samples.findFile(cheminPhoto))
    x = int(img.shape[0]/2)
    y = int(img.shape[1]/2)
    r = 1
    json_dic["circle_0"] = createJsonCircle(x, y, r)
    return json_dic


def createCrop(img, x, y, r):
    rectX = (x - r)
    rectY = (y - r)
    crop_img = img[rectY:(rectY+2*r), rectX:(rectX+2*r)]
    return crop_img
