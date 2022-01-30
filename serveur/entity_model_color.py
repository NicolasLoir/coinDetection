# from matplotlib import colors
from entity_analyse import executeAnalyse, createCrop, analyseHoughCircleInside
import cv2
import os
import math
import numpy as np
from sklearn.cluster import KMeans
from trying_model_color import showKmeans, improveContrast
import random


def createCropWithBackGround(imageCrop, r):
    image = imageCrop.copy()
    imgX = image.shape[0]
    imgY = image.shape[1]
    imgMax = math.sqrt(imgX*imgX + imgY*imgY) / 2
    center_coordinates = (int(imgX/2), int(imgY/2))
    radius = int(imgMax)
    color = (255, 0, 0)
    thickness = int((imgMax - r) * 2)
    image = cv2.circle(image, center_coordinates,
                       radius, color, thickness)
    return image


def centroid_histogram(clt):
    numLabels = np.arange(0, len(np.unique(clt.labels_)) + 1)
    (hist, _) = np.histogram(clt.labels_, bins=numLabels)
    # normalize the histogram, such that it sums to one
    hist = hist.astype("float")
    hist /= hist.sum()
    return hist


def getValueFromColor(image):
    # showKmeans(image, 2)  # pour voir le cluster de la photo
    photoImage = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = photoImage.reshape((photoImage.shape[0] * photoImage.shape[1], 3))
    clt = KMeans(n_clusters=2)
    clt.fit(image)
    hist = centroid_histogram(clt)
    findBlueCentroid = False
    sentenceToPrint = ""
    arrayToReturn = []
    # loop over the percentage of each cluster and the color of # each cluster
    for (percent, color) in zip(hist, clt.cluster_centers_):
        colors = color.astype("uint8").tolist()
        red = colors[0]
        green = colors[1]
        blue = colors[2]
        # recherche d'une couleur bleu principale, cf photo 13 pose pb
        if (red < 5 and green < 5 and blue > 250):
            findBlueCentroid = True
        else:
            arrayToReturn.append("success")
            arrayToReturn.append(colors)
            sentenceToPrint += str(colors) + " " + str(percent) + "\n"
    if (findBlueCentroid):
        # print(sentenceToPrint)
        return arrayToReturn
    else:
        # print("Couleur bleu non détecté, impossible de savoir la couleur dominante de la piece")
        return ["error"]


def findPartCircle(imageCrop, r, idAnalyse):
    partCircleFind = False
    # on garde juste le centre de la piece, les chiffres se trouve à cette endroit pour 10, 20, 50
    imageCrop3 = createCropWithBackGround(imageCrop, r/2)
    # cv2.imshow("img", imageCrop3)
    # cv2.waitKey(0)
    namePhotoTemp = "./tempCrop.png"
    cv2.imwrite(namePhotoTemp, imageCrop3)
    listPhoto = analyseHoughCircleInside(idAnalyse, namePhotoTemp)
    # print("listPhoto", listPhoto)
    for photo in listPhoto:
        partCircleFind = True
        x = listPhoto[photo]["x"]
        y = listPhoto[photo]["y"]
        r = listPhoto[photo]["r"]
        imageCropFinal = createCrop(imageCrop, x, y, r)
        # cv2.imshow("img", imageCropFinal)
        # cv2.waitKey(0)
        break
    return partCircleFind


def findClassPhotoColor(imageCrop, r, idAnalyse):
    valuePiece = 0
    # imageCrop = improveContrast(imageCrop) #améliore le contraste masi modifier le RDGB, moins performant avec
    # cv2.imshow('imageWithContrast', imageCrop)
    imageCrop = createCropWithBackGround(imageCrop, r)

    value1 = getValueFromColor(imageCrop)
    # on retire la bordure externe (pour différencier 1/2€ du reste)
    imageCrop2 = createCropWithBackGround(imageCrop, r - (r/3))
    value2 = getValueFromColor(imageCrop2)
    if (value1[0] == "success" and value2[0] == "success"):
        colors1 = value1[1]
        colors2 = value2[1]
        # print(colors1)
        # print(colors2)
        # si la couleur rouge est 1.35 dominante par rapport au vert et bleu
        if (colors1[0] > 1.35 * colors1[1] and colors1[0] > 1.35 * colors1[2] and
                colors2[0] > 1.35 * colors2[1] and colors2[0] > 1.35 * colors2[2]):
            # print("couleur rouge")
            valuePiece = 5
        # si tres peu de variation avec et sans bordure on a la choix entre 10, 20 et 50 centimes
        elif (abs(colors1[0] - colors2[0]) < 5 and abs(colors1[1] - colors2[1]) < 5 and abs(colors1[2] - colors2[2]) < 5):
            # print("10 20 50")
            partCircleFind = findPartCircle(imageCrop, r, idAnalyse)
            if (partCircleFind):
                # print("partCircleFind")
                rand = random.uniform(1, 10)
                # print("rand", rand)
                if (rand >= 5):
                    # 6 chance sur 10 d'être une piece de 50
                    valuePiece = 50
                else:
                    valuePiece = 20
            else:
                valuePiece = 10
        else:
            # une chance sur deux d'être 1 ou 2 euros
            if (colors1[0] > colors2[0]):
                valuePiece = 100
            else:
                valuePiece = 200
    else:
        print("on ne peut pas prédire")
        listPossibleValue = [5, 10, 20, 50, 100, 200]
        valuePiece = listPossibleValue[random.uniform(0, 5)]
    return valuePiece


def mainWithPrediction():
    namePhoto = "ZQAEUMoCI6Vl3mWYL0efSg1NC5h1_22"
    cheminPhoto = os.path.join('static', 'photoUser', namePhoto + ".jpg")

    img = cv2.imread(cv2.samples.findFile(cheminPhoto))
    idAnalyse = 2
    listPhoto = executeAnalyse(idAnalyse, cheminPhoto)
    # print(listPhoto)

    cpt = 0
    for photo in listPhoto:
        print("tour " + str(cpt))
        x = listPhoto[photo]["x"]
        y = listPhoto[photo]["y"]
        r = listPhoto[photo]["r"]
        imageCrop = createCrop(img, x, y, r)
        print(findClassPhotoColor(imageCrop, r, idAnalyse))
        cv2.imshow("img", imageCrop)
        cv2.waitKey(0)
        cpt += 1


# mainWithPrediction()
