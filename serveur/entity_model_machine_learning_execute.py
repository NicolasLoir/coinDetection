from keras.preprocessing.image import img_to_array
from keras.models import load_model
import numpy as np
import pickle
import cv2


def classifier(img):
    print("Chargement du réseau...")
    model = load_model("./trainingModelV1.h5")
    lb = pickle.loads(open("lab.pickle", "rb").read())
    name, score = classify(img, model, lb)
    print(name)
    print(score)
    # pas le temps de finir, il faudrait mettre le estUnePiece a false
    if (name == "bin"):
        return 5
    return name


def classify(img, model, lb):
    # pre-process
    # rappel aux dimensions du modele entrainé
    image = cv2.resize(img, (96, 96))
    image = image.astype("float") / 255.0
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    # prediction
    proba = model.predict(image)[0]
    idx = np.argmax(proba)
    label = lb.classes_[idx]
    print(proba)
    return label, proba[idx] * 100


# name_file = "../photo/photo_classe/10/P001.jpg"
# img = cv2.imread(name_file)
# classifier(img)
# test_classifier("/Users/nicolas/Documents/IMT/vision/tp4/ex3.jpg")
# print("ok")
