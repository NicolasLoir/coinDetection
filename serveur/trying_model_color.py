import matplotlib.pyplot as plt
import cv2
from sklearn.cluster import KMeans
import numpy as np


def plot_colors(hist, centroids):
    bar = np.zeros((50, 300, 3), dtype="uint8")
    startX = 0
    findBlueCentroid = False
    sentenceToPrint = ""
    # loop over the percentage of each cluster and the color of # each cluster
    for (percent, color) in zip(hist, centroids):
        # print(percent)
        colors = color.astype("uint8").tolist()
        red = colors[0]
        green = colors[1]
        blue = colors[2]
        if (red < 5 and green < 5 and blue > 250):
            findBlueCentroid = True
            print()
        else:
            sentenceToPrint += str(colors) + " " + str(percent) + "\n"
            # print(colors, percent)
        # plot the relative percentage of each cluster
        endX = startX + (percent * 300)
        cv2.rectangle(bar, (int(startX), 0), (int(endX), 50),
                      colors, -1)
        startX = endX
    if (findBlueCentroid):
        print(sentenceToPrint)
    else:
        print("Couleur bleu non détecté, impossible de savoir la couleur dominante de la piece")
    return bar


def centroid_histogram(clt):
    numLabels = np.arange(0, len(np.unique(clt.labels_)) + 1)
    (hist, _) = np.histogram(clt.labels_, bins=numLabels)
    # normalize the histogram, such that it sums to one
    hist = hist.astype("float")
    hist /= hist.sum()
    return hist


def showKmeans(image, cluster):
    photoImage = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = photoImage.reshape((photoImage.shape[0] * photoImage.shape[1], 3))
    clt = KMeans(n_clusters=cluster)
    clt.fit(image)

    # recuperer le nombre de cluster
    hist = centroid_histogram(clt)
    bar = plot_colors(hist, clt.cluster_centers_)

    # plot
    fig = plt.figure(figsize=(10, 7))
    rows = 2
    columns = 1

    fig.add_subplot(rows, columns, 1)
    plt.imshow(photoImage)
    plt.axis('off')
    plt.title("Photo")

    fig.add_subplot(rows, columns, 2)
    plt.imshow(bar)
    plt.axis('off')
    plt.title("Cluster")

    plt.show()


def improveContrast(img):
    # -----Converting image to LAB Color model-----------------------------------
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    # -----Splitting the LAB image to different channels-------------------------
    l, a, b = cv2.split(lab)
    # -----Applying CLAHE to L-channel-------------------------------------------
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    cl = clahe.apply(l)
    # -----Merge the CLAHE enhanced L-channel with the a and b channel-----------
    limg = cv2.merge((cl, a, b))
    # -----Converting image from LAB Color model to RGB model--------------------
    final = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
    return final
