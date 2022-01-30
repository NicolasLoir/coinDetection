import os
import cv2
import pickle
import random
import argparse
import numpy as np
from imutils import paths
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from VGGNet import SmallerVGGNet
from sklearn.preprocessing import LabelBinarizer
from keras.preprocessing.image import img_to_array
from keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.optimizers import Adam
import matplotlib
matplotlib.use("Agg")


def train():
    # epochs, learning rate, batch size, image dimensions
    EPOCHS = 100
    INIT_LR = 0.001
    BS = 32
    IMAGE_DIMS = (96, 96, 3)
    # Tableau de données et labels (fr : etiquettes)
    data = []
    labels = []
    # On récupere le chemin de nos images et on les mélanges aléatoirement
    print("[INFO] Chargement des images")
    imagePaths = sorted(list(paths.list_images(
        "./photo_classe")))
    random.seed(42)
    random.shuffle(imagePaths)

    # Boucle sur les images
    for imagePath in imagePaths:
        # print(imagePath)
        # Lecture des images et préparation de celles-ci aux dimensions adapté pour
        image = cv2.imread(imagePath)
        scale_percent = 60  # percent of original size
        # width = int(image.shape[1] * scale_percent / 100)
        # height = int(image.shape[0] * scale_percent / 100)
        # Toutes les images doivent avoir la même dimension sinon pb data = np.array(data, dtype="float")
        dim = (96, 96)
        image = cv2.resize(image, dim)
        image = img_to_array(image)
        # donnees
        data.append(image)
        # etiquettes
        label = imagePath.split(os.path.sep)[-2]
        labels.append(label)

    data = np.array(data, dtype="float")
    data = data / 255.0
    labels = np.array(labels)

    # print(data)

    # binariser les labels
    lb = LabelBinarizer()
    labels = lb.fit_transform(labels)
    # On effectue un split de notre dataset
    # train = 80% et test = 20% dans notre cas
    (trainX, testX, trainY, testY) = train_test_split(
        data, labels, test_size=0.2, random_state=42)
    # On effectue une augementation virtuelle des données
    # Pratique si peux d'images mais attention à ne pas en abuser
    datagen = ImageDataGenerator(rotation_range=25, width_shift_range=0.1, height_shift_range=0.1,
                                 shear_range=0.2, zoom_range=0.2, horizontal_flip=True, fill_mode="nearest")

    print("ok avant init et compilation")

    # IInit et compilation
    model = SmallerVGGNet.build(width=IMAGE_DIMS[1], height=IMAGE_DIMS[0], depth=IMAGE_DIMS[2],
                                classes=len(lb.classes_))
    opt = Adam(learning_rate=INIT_LR, decay=INIT_LR / EPOCHS)
    model.compile(loss="categorical_crossentropy",
                  optimizer=opt, metrics=["accuracy"])

    print("ok avant entrainement du réseau")

    # Entrainement du réseau
    H = model.fit(
        datagen.flow(trainX, trainY, batch_size=BS),
        validation_data=(testX, testY),
        steps_per_epoch=len(trainX) // BS,
        epochs=EPOCHS,
        verbose=1)
    # Enregistrement du model et de la labelisation
    model.save("./trainingModelV1.h5")
    f = open("lab.pickle", "wb")
    f.write(pickle.dumps(lb))
    f.close()

    # plot the training loss and accuracy
    plt.style.use("ggplot")
    plt.figure()
    N = EPOCHS
    print(H.history)
    # Training loss is the error on the training set of data
    plt.plot(np.arange(0, N), H.history["loss"], label="training_loss")
    # Validation loss is the error after running the validation set of data through the trained network.
    plt.plot(np.arange(0, N), H.history["val_loss"], label="validation_loss")
    #  EXEMPLE : ~training_accuracy=86% on the training set and
    plt.plot(np.arange(0, N), H.history["accuracy"], label="training_accuracy")
    # ~validation_accuracy=84% on the validation set
    # . This means that you can expect your model to perform with ~84% accuracy on new data.
    plt.plot(np.arange(0, N),
             H.history["val_accuracy"], label="validation_accuracy")
    plt.title("Training Loss and Accuracy")
    plt.xlabel("Epoch #")
    plt.ylabel("Loss/Accuracy")
    plt.legend(loc="upper left")
    plt.savefig('./figureTraining')


train()
print('ok')
