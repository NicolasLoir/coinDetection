# import les insert de analyse, dataset, creer model dans cet ordre

from bdd_analyse import saveAnalyseBDD
from bdd_dataset import saveDatasetBDD, datasetExiste
from entity_model import createModelDummy1, createModelDummy2, createModelColor, createModelMachineLearning
from bdd_personne import savePersonneBDD


def createModelBDD(idModel, idDataset):
    if (datasetExiste(idDataset)):
        if (idModel == 1):
            createModelDummy1(idModel, idDataset)
        elif (idModel == 2):
            createModelDummy2(idModel, idDataset)
        elif (idModel == 3):
            createModelColor(idModel, idDataset)
        elif (idModel == 4):
            createModelMachineLearning(idModel, idDataset)
        else:
            print("Pas de modele associé à l'idModel %d" % idModel)
    else:
        print(
            "Pas de dataset existant pour l'id %d. Création de model impossible" % idDataset)


def create():
    saveAnalyseBDD(1, "analyseHoughCircleWide")
    saveAnalyseBDD(2, "analyseHoughCircleNormal")
    saveAnalyseBDD(3, "analyseHoughCircleCLose")
    saveAnalyseBDD(4, "analyseHoughCircleSuperWide")
    # saveAnalyseBDD(5, "analyseHoughCircleSuperCLose")
    saveDatasetBDD(1, "dummyDatasetNoAnalyse", "./photo/photo_1")
    saveDatasetBDD(2, "dummyDatasetCopyAnalyse", "./photo/photo_copy", 2)
    saveDatasetBDD(1, "colorDetection", "./photo/photo_1")
    createModelBDD(1, 2)
    createModelBDD(2, 2)
    createModelBDD(3, 2)
    createModelBDD(4, 1)
    # print(executeModel(1, "photo"))
    savePersonneBDD('ZQAEUMoCI6Vl3mWYL0efSg1NC5h1')
    savePersonneBDD('wJJ4bGGE0YbC8FemPACPNmV0cQF2')
    savePersonneBDD('yolo')


# create()
