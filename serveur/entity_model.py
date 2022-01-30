from bdd_model import getChemin, saveModelBDD
from entity_model_color import findClassPhotoColor
from entity_model_machine_learning_execute import classifier
from entity_model_color import createCropWithBackGround

# ---------------------- CREATE ---------------------------


def createModelDummy1(idModel, idDataset):
    nomModel = "modeleDummy1"
    cheminModel = '../model/modeleDummy1.txt'
    f = open(cheminModel, "w")
    f.write("100")
    f.close()
    saveModelBDD(idModel, nomModel, cheminModel, idDataset)


def createModelDummy2(idModel, idDataset):
    nomModel = "modeleDummy2"
    cheminModel = '../model/modeleDummy2.txt'
    f = open(cheminModel, "w")
    f.write("200")
    f.close()
    saveModelBDD(idModel, nomModel, cheminModel, idDataset)


def createModelColor(idModel, idDataset):
    nomModel = "color"
    cheminModel = 'vide'
    saveModelBDD(idModel, nomModel, cheminModel, idDataset)


def createModelMachineLearning(idModel, idDataset):
    nomModel = "machineLearning"
    cheminModel = "'noNeed'"
    saveModelBDD(idModel, nomModel, cheminModel, idDataset)

# ------------------------USE---------------------------


def executeModel(idModel, photo, r, idAnalyse):
    if (idModel == 1):
        return executeModelDummy1(idModel, photo)
    elif (idModel == 2):
        return executeModelDummy2(idModel, photo)
    elif (idModel == 3):
        return findClassPhotoColor(photo, r, idAnalyse)
    elif (idModel == 4):
        imageBackground = createCropWithBackGround(photo, r)
        return classifier(imageBackground)
    else:
        print("Pas de modele associé à l'idModel %d" % idModel)


def executeModelDummy1(idModel, photo):
    cheminModel = getChemin(idModel)
    return analysePhoto(cheminModel, photo)


def executeModelDummy2(idModel, photo):
    cheminModel = getChemin(idModel)
    return analysePhoto(cheminModel, photo)


def analysePhoto(cheminModel, photo):
    f = open(cheminModel, "r")
    contenu = f.read()
    return contenu
