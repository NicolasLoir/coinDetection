from utils_bdd_connect import commitBDD, selectBDD


def saveDatasetBDD(idDataset, nameDataset, pathDataset, idAnalyse=None):
    try:
        dataset = selectBDD(
            "SELECT * FROM dataset WHERE id_dataset = %d" % idDataset)
        if (len(dataset) > 0):
            commitBDD("UPDATE dataset SET name_dataset = '%s', path_dataset = '%s' WHERE id_dataset = %d" % (
                nameDataset, pathDataset, idDataset))
        else:
            commitBDD("INSERT INTO dataset (id_dataset, name_dataset, path_dataset) VALUES (%d, '%s', '%s');" % (
                idDataset, nameDataset, pathDataset))
        sentence_print = "Le dataset %d nommé %s est sauvegardé en bdd" % (
            idDataset, nameDataset)
        if (idAnalyse):
            commitBDD("UPDATE dataset SET id_analyse = %d WHERE id_dataset = %d" % (
                idAnalyse, idDataset))
            sentence_print += ". L' idAnalyse utilisé est %d" % idAnalyse
        print(sentence_print)
    except Exception as e:
        print(e)


def selectCheminDataset(idDataset):
    try:
        dataset = selectBDD(
            "SELECT path_dataset FROM dataset WHERE id_dataset = %d" % idDataset)
        path_dataset = dataset[0][0]
        return path_dataset
    except Exception as e:
        print(e)


def datasetExiste(idDataset):
    try:
        dataset = selectBDD(
            "SELECT * FROM dataset WHERE id_dataset = %d" % idDataset)
        if (len(dataset) > 0):
            return True
        else:
            return False
    except Exception as e:
        print(e)
        return False
