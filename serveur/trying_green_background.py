from entity_analyse import executeAnalyse, createCrop
import cv2
import os
import json
import math
import numpy as np
from PIL import Image

"""
J'ai essayé de supperposer sur une image carré vert de 1024 par 1024 mes pieces pour avoir un fond uniforme
Erreur;
Traceback (most recent call last):
  File "trying_greenbackground.py", line 99, in <module>
    listPointVert, copy_img_vert)
  File "trying_greenbackground.py", line 60, in add_element
    alpha_mask = transformed_mask[:, :, 3]
IndexError: index 3 is out of bounds for axis 2 with size 3

Provient probablement du fait que j'essaie d'ajouter une image contenant ma piece qui n'a pas un canal de transparence
"""


def makeBlueTransparant(imageCrop):
    # Ne fonctionne pas car cv2 ne prend pas en compte le canal alpha
    pathTempImage = './tempCrop.png'
    cv2.imwrite(pathTempImage, imageCrop)
    img = Image.open('./tempCrop.png')
    img = img.convert("RGBA")
    datas = img.getdata()

    newData = []
    for item in datas:
        if item[0] == 0 and item[1] == 0 and item[2] == 255:
            newData.append((0, 0, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(pathTempImage, "PNG")
    image = cv2.imread(cv2.samples.findFile(pathTempImage))
    cv2.imshow("img", image)
    cv2.waitKey(0)
    return image


def add_circle(list_point, img):
    for (x, y) in list_point:
        center_coordinates = (x, y)
        radius = 20
        color = (255, 0, 0)
        thickness = 5
        image = cv2.circle(img, center_coordinates, radius, color, thickness)
    return image


def getCirclePoint(nbPoints, x, y, r):
    finalArray = []
    slice = 2 * math.pi / nbPoints
    for i in range(nbPoints):
        angle = slice * i
        newX = (int)(x + r * math.cos(angle))
        newY = (int)(y + r * math.sin(angle))
        newArray = [newX, newY]
        finalArray.append(newArray)
    numpyArray = np.array(finalArray)
    return numpyArray


def add_element(path_img_ajouter, pt_elmt_ajouter, pt_elmt_origine, copy_img_origin):
    print("path_img_ajouter")
    print(path_img_ajouter)
    print("pt_elmt_ajouter")
    print(pt_elmt_ajouter)
    print("pt_elmt_origine")
    print(pt_elmt_origine)
    print("copy_img_origin")
    print(copy_img_origin)
    image_ajouter = cv2.imread(path_img_ajouter, cv2.IMREAD_UNCHANGED)
    image_ajouter = image_ajouter.astype(np.float32)
    image_ajouter = image_ajouter / 255.0

    M, _ = cv2.findHomography(pt_elmt_ajouter, pt_elmt_origine)

    max_width = copy_img_origin.shape[1]
    max_height = copy_img_origin.shape[0]

    transformed_mask = cv2.warpPerspective(
        image_ajouter,
        M,
        (max_width, max_height),
        None,
        cv2.INTER_LINEAR,
        cv2.BORDER_CONSTANT,
    )

    # print(transformed_mask)
    alpha_mask = transformed_mask[:, :, 3]
    alpha_image = 1 - alpha_mask

    for c in range(0, 3):
        copy_img_origin[:, :, c] = (
            alpha_mask * transformed_mask[:, :, c]
            + alpha_image * copy_img_origin[:, :, c]
        )
    return copy_img_origin


namePhotoVert = "carre_vert"
cheminPhotoVert = os.path.join('..', 'photo', namePhotoVert + ".png")

imgVert = cv2.imread(cv2.samples.findFile(cheminPhotoVert))

c = 512
listPointVert = getCirclePoint(20, c, c, c)
imgVert = add_circle(listPointVert, imgVert)
copy_img_vert = imgVert.copy()
copy_img_vert = copy_img_vert.astype(np.float32) / 255.0
cv2.imshow("img", imgVert)
cv2.waitKey(0)

namePhoto = "ZQAEUMoCI6Vl3mWYL0efSg1NC5h1_13"
cheminPhoto = os.path.join('static', 'photoUser', namePhoto + ".jpg")

img = cv2.imread(cv2.samples.findFile(cheminPhoto))

listPhoto = executeAnalyse(2, cheminPhoto)
print(listPhoto)

for photo in listPhoto:
    x = listPhoto[photo]["x"]
    y = listPhoto[photo]["y"]
    r = listPhoto[photo]["r"]
    listPoint = getCirclePoint(20, x, y, r)
    # img = add_circle(listPoint, img)
    imageFinal = add_element(cheminPhoto, listPoint,
                             listPointVert, copy_img_vert)
    cv2.imshow("img", imageFinal)
    cv2.waitKey(0)


# cv2.imshow("img", img)
# cv2.waitKey(0)
